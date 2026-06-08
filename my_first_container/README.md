# Eerste stapjes in Docker
Doel van deze opdracht is om te ervaren:
* Wat is een container?
* Waar gebruik je een image voor?
* En hoe kan je met veranderende bestanden omgaan (docker volumes).

---

## nginx
In deze opdracht gaan we een image gebruiken van [nginx](https://nginx.org/en/). Deze image bevat een applicatie welke veel gebruikt wordt als webserver, reverse proxy, loadbalancer etc. In deze opdracht gebruiken we puur het webserver deel om visueel te maken wat er gebeurt met bestanden die we veranderen.

---

## Wat is een container?
1. **Start een container:**
   ```bash
   docker run --name test01 --rm -p 8889:80 nginx
   ```

| Parameter | Doel |
| :--- | :--- |
| **`docker run`** | samenvoeging van docker create en docker start. Maakt een nieuwe container op basis van een opgegeven image |
| **`--name test01`** | Geeft de nieuwe container een naam, zonder deze parameter krijgt hij willekeurig een naam toegewezen |
| **`--rm`** | Als je deze weglaat blijft de container bestaan bij het stoppen. Door --rm op te geven wordt de container na uitvoer verwijderd. |
| **`-p 8889:80`** | Poort routering; poort 8889 van de host wordt gekoppeld aan poort 80 van de container |
| **`nginx`** | De naam van de image voor onze container. Als deze niet bestaat zal hij automatisch worden gezocht op docker hub tenzij in de image een andere url is verwerkt. |

Omdat we docker gestart hebben *zonder* de optie `-d` wordt het commando niet op de achtergrond gestart. De uitvoer van processen in de container worden daardoor getoond en je krijg niet meteen je prompt terug.

2. **Bezoek de website:**  
   Open een webbrowser en ga naar je VM op poort `8889`.
   Als je naar het venster kijkt waarop de container is gestart zou je daar de logging terug moeten zien.

3. **Log in op de container:**  
   Open een nieuwe console en open een shell in de draaiende container:
   ```bash
   docker exec -ti test01 bash
   ```
| Parameter | Doel |
| :--- | :--- |
| **`docker exec`** | Dit zorgt dat we verbinden met een draaiende container en daarin een commando starten |
| **`-ti`** | Nodig om interactief op de tty te verbinden |
| **`test01`** | De naam van de container |
| **`bash`** | Het programma dat we willen starten in de container |

---

## File mutaties
1. **Pas de inhoud aan:**  
   Overschrijf de index.html met eigen tekst:
   ```bash
   echo "vier-nul-vier" > /usr/share/nginx/html/index.html
   ```

2. **Controleer het resultaat:**  
   Wat krijg je te zien als je de pagina in je browser ververst?

   Als het goed is zien we nu de inhoud van het aangepaste bestand

3. **Stop de container:**  
   Druk op `CTRL-C` in het originele terminalvenster waarin je container is gestart. De logging zal nu stoppen en je krijgt je prompt terug.

4. **Start opnieuw & vergelijk:**  
   Start de container opnieuw. Het vorige commando is op te roepen met het pijltje omhoog gevolgd door 'Enter'.Wat krijg je nu te zien als je de pagina in je browser ververst?

   Bestanden die in een bestaande image worden vervangen, zullen tijdelijk een extra layer krijgen. Deze is echter alleen gekoppeld aan de container en indien je geen bijzondere maatregelen treft zal je al deze gewijzigde data verliezen.

5. **Stop en verwijder de container**
   Vanuit een ander terminalvenster:
   ```bash
   docker kill test01
   ```

   Of `CTRL-C` vanuit het venster waarin Docker gestart was...

   Omdat de container origineel is gestart met de parameter `--rm` zal deze automatisch worden opgeruimd nadat deze stopt.

6. **Start een container met het volgende commando:**
   ```bash
   docker run --name test02 --rm -p 8889:80 -v /opt/workshop/my_first_container/index.html:/usr/share/nginx/html/index.html nginx
   ```

   De optie `-v` koppelt een map op de disk van de VM, aan een map in de draaiende container.

7. **Pas de index.html aan**
   ```bash
   cd /opt/workshop/my_first_container
   echo "Bye!" > index.html
   ```
   Welke pagina wordt nu geserveerd?
   En wat krijg je na een:
   ```bash
   git restore index.html
   ```
---

# Conclusie
* Een bestand in het image kan gewoon worden aangepast en binnen de draaiende container zal deze mutatie worden bewaard tot de container zelf wordt opgeruimd.
* Met een `-v` ofwel bind-mount kan een map op de VM worden gekoppeld aan een map in een draaiende container. Op deze manier houden we deze opslag 'persistent'.
* Er zijn ook named volumes. Deze hebben andere voordelen maar zijn voor deze oefening even buiten scope.

---

Mocht je de proces isolatie niet willen missen kan je hieronder de verdieping terug vinden, anders gaan we door naar de 2e opdracht: [De container images](../my_first_image/)

---

# Verdieping
## Proces isolatie
* 1. Start een container met nginx:
```bash
docker run --name test03 --rm -p 8889:80 nginx
```

* 2. Start in een andere terminal een bash shell in de draaiende container:
```bash
docker exec -ti test03 bash
```

* 3. Roep in die container de lijst op van draaiende processen:
```bash
ls -l /proc/*/exe
```
Normaal zou je wellicht het commando `ps` gebruiken, deze is echter niet aanwezig in deze container image.

De lijst met processen is als het goed is erg kort...

* 4. Voer vervolgens buiten de container het volgende commando uit:
```bash
ls -l /proc/*/exe
```

Deze lijst zou een *stuk* langer moeten zijn. Hierin is uiteindelijk ook het nginx proces te vinden welke ook draaide in de container.

---

## Conclusie
Vanuit de `host` zijn alle processen zichtbaar. Vanuit een container alleen processen in dezelfde namespace. Hiervoor zorgt de containerd runtime.

Mocht je nu op de `host` een process tegenkomen waarvan je wil weten bij welke container deze hoort kan je hiervoor de volgende truuk gebruiken:

```bash
nsenter -t [process id] -a hostname
```
Dit commando zal de namespace binnengaan horende bij het process id. Vervolgens binnen deze namespace zal hij het commando hostname uitvoeren. Dit geeft de hostname terug van de container. Deze is vervolgens verder te inspecteren met:
```bash
docker inspect [hostname]
```
![Process isolatie](./proc%20isolation.png)