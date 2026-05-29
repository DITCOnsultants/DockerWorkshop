Doel:
- Wat is een container
- Wat is een image
- Waar gebruik je volumes voor


1. **Start de container:**
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

2. **Bezoek de website:**  
   Open een webbrowser en ga naar je VM op poort `8889`.

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

4. **Pas de inhoud aan:**  
   Overschrijf de index.html met eigen tekst:
   ```bash
   echo "vier-nul-vier" > /usr/share/nginx/html/index.html
   ```

5. **Controleer het resultaat:**  
   Wat krijg je te zien als je de pagina in je browser ververst?

6. **Stop de container:**  
   Druk op `CTRL-C` in het terminalvenster waarin je container is gestart.

7. **Start opnieuw & vergelijk:**  
   Start de container opnieuw. Wat krijg je nu te zien als je de pagina ververst?

8. **Stop en verwijder de container**
   ```bash
   docker kill test01
   docker rm test01
   ```
8. **Start een container met het volgende commando:**
   ```bash
   docker run --name test02 --rm -p 8889:80 -v /opt/workshop/my_first_container/index.html:/usr/share/nginx/html/index.html nginx
   ```
