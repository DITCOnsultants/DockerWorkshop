# Images maken
Doel:
- Hoe maak ik een eigen image?
- Wat kan ik met een eigen image?

---

## Maak een eigen image:
```bash
docker build . -t testimage01
```

| Parameter | Doel |
| :--- | :--- |
| **`docker build`** | Bouw een nieuwe image |
| **`.`** | Geeft de locatie aan van de 'Dockerfile' |
| **`-t`** | Geef de image een tag/naam |

---

## Wat doet een Dockerfile?
Iedere regel in een Dockerfile resulteert normaal gesproken in een extra layer.
Te beginnen met een *FROM* (importeer een bestaande image) en gevolgd door allerlei bewerkingen om bestanden te kopieren, commando's uit te voeren etc.
```dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

In dit geval nemen we de nginx image uit de vorige opdracht en kopieren de index.html naar de webmap.

---

## Start je image

We gaan nu een container start op basis van de image die we net gemaakt hebben:
```bash
docker run -d --name imagetest01 --rm -p 8889:80 testimage01
```

Bezoek vervolgens vanuit je browser de nieuwe webserver op http://[vm-ip]:8889 en nu zou je gegroet moeten worden met een 'Hello World' pagina. De default pagina van de nginx image is nu permanent overschreven met onze eigen index.html.

---
## Tags / De naam van een image

De naam van een image kan bestaan uit meerdere componenten:
```docker
privatehub.mycompany.local/project_x/application_server:testing
```

| Component | Vereist | Doel |
| :--- | :--- | :--- |
| **`privatehub.mycompany.local`** | Optioneel | URL van de registry, indien niet opgegeven wordt automatisch hub.docker.com gebruikt |
| **`project_x`** | Optioneel | Binnen een registry kan een boomstructuur aan mappen bestaan, afhankelijk van de software gebruikt |
| **`application_server`** | Vereist | naam van de image |
| **`testing`** | Optioneel | Tag van de image, indien niet opgegeven zal dit altijd `latest` zijn | 

Eerder hebben we `nginx` als image gebruikt. Deze had geen URL en is dus bij hub.docker.com gedownload. De tag was niet gespecificeerd en dus is `latest` hiervoor gebruikt.

```bash
eric@testlab:~$ docker image ls
REPOSITORY                        TAG       IMAGE ID       CREATED             SIZE
nginx                             latest    7aaca76c508f   2 weeks ago         161MB
python                            3-slim    69951c9faec3   2 weeks ago         119MB
testimage01                       latest    81460f6ed531   About an hour ago   161MB
```

---

## Updates en aanpassingen

Een traditionele server of VM zou je dagelijks/wekelijks/'maandelijks' moeten voorzien van de laatste security updates. Een docker image is immutable. Een update installeren is dus niet handig gezien het tijdelijke karakter van een container.

In plaats daarvan zal de maintainer van een officiele docker image, voor iedere update/patch een nieuwe image publiceren. Kleine patches/updates vinden vaak plaats onder dezelfde `tag` zodat deze naadloos kunnen worden herstart naar de nieuwe versies. Voor major releases moet je soms de tag aanpassen.

---

## Update werkwijze
Zie hier een voorbeeld...

### 1. Image bijwerken
Pas de index.html aan (Hello updated world?) en maak een nieuwe image:
```bash
docker build . -t testimage01
```

Nu de nieuwe image is gemaakt wordt deze nog nergens gebruikt. De draaiende container zal nog gewoon 'Hello World' laten zien.

### 2. Vervang de container
Stop de container... Verwijder de container...
```bash
docker stop imagetest01
docker rm imagetest01
```
En start een nieuwe...
```bash
docker run -d --name imagetest01 --rm -p 8889:80 testimage01
```

### 3. Controleer of de nieuwe image in gebruik is
Als je nu de browser laat verversen zou je de nieuwe content moeten zien...

---

## Omslachtig
Zoals je ziet is het beheren van docker containers best een dingetje.
Als je complexere containers draait waarin je bij het maken mee moet geven:
* Een lijst van poorten
* Labels
* Environment vars
* Naam van de container
* Aangepast netwerk
* Volumes om te mounten
* ...

Dan is het 'even' updaten niet leuk meer.

---

## docker-compose
Om dit allemaal een stuk gemakkelijker te maken hebben we de beschikking over docker-compose.

```docker-compose
services:
  imagetest01:
    name: imagetest01
    image: testimage01
    ports:
      - 8889:80
```
Dit is een voorbeeld van een `docker-compose.yml` en zo kunnen we de informatie die we nodig hebben om een container te starten gemakkelijk opslaan in code.

Het starten van de container gaat dan als volgt:

```bash
docker-compose up -d
```
En wanneer we de file hebben aangepast, of er is een nieuwe image beschikbaar. Kunnen we deze mutatie activeren met:

```bash
docker-compose up -d
```
(Indien we de bijgewerkte image nog niet lokaal hebben dienen we eerst `docker-compose pull` te draaien)

In een docker-compose.yml is het mogelijk om meerdere containers te beschrijven, relaties hiertussen vast te leggen en om dynamisch containers aan elkaar te knopen. Een voorbeeld hiervan is te vinden in de LVT map.

# Verdieping

## Volgorde en efficiency
Zoals zojuist vermeld zorgt iedere regel in een Dockerfile voor een nieuwe laag. Deze lagen worden allemaal opgeslagen aan de hand van de hash van de laag.

Stel je hebt 10 images allemaal gebaseerd op dezelfde basis image; deze wordt door deze structuur maar 1 keer opgeslagen. Een image is immers immutible en wordt opgeslagen op basis van de hash. Een goede vorm van deduplicatie.

Stel je nu voor dat je de volgende 2 Dockerfiles hebt:

Image 1
```Dockerfile
# Basis image op basis van Python
FROM python:3-slim
# Installeer een Python module genaamd: flask
RUN pip3 install --no-cache-dir flask
# Maak een user aan
RUN useradd nonroot
# Copieer het testscript in de image
COPY ./testscript1.py /app/
# Verander de actieve user
USER nonroot
# Het commando om te draaien bij het starten van de container
CMD ["/app/testscript1.py"]
```

Image 2
```Dockerfile
# Basis image op basis van Python
FROM python:3-slim
# Installeer een andere Python module genaamd: pandas
RUN pip3 install --no-cache-dir pandas
# Maak een user aan
RUN useradd nonroot
# Copieer een ander testscript in de image
COPY ./testscript2.py /app/
# Verander de actieve user
USER nonroot
# Het commando om te draaien bij het starten van de container
CMD ["/app/testscript2.py"]
```

Beide docker images gebruiken dezelfde basis image, deze ruimte wordt maar 1 keer gebruikt (zowel op disk als eventueel in een registry).

Regel 2 is echter anders voor beide images. Dit zorgt ervoor dat gelijke acties later in de Dockerfile toch een andere hash krijgen waardoor dedup hier niet mogelijk is.

Door bijvoorbeeld de installatie van de Python module naar beneden te verplaatsen blijft een groter deel van de layer gelijk aan elkaar en zal zowel de opslag als het bouwen van de images efficienter verlopen.

Door met het commando `docker inspect` de images te bekijken zien we de layers in deze images. De basis image had 4 layers en deze zien we ook terug in onze eigen images als de eerste 4 hashes. Regels 2 t/m 4 resulteerden ook in een nieuwe layer en die 3 zien we per image verschillen. De `USER` en `CMD` regels passen geen bestanden aan en resulteren dus niet in een extra layer. Deze informatie wordt als metadata bij het image opgeslagen.

```bash
docker inspect python:3-slim
```
```
[..]
  "Layers": [
        "sha256:219a998c60509502b47b97f1158067d5dd62640d2d689560d32cfd5594f6bc40",
        "sha256:8258db9b59a3c0bdb28a9f64841c53636ec5646c60a16867e4e7327b64b69482",
        "sha256:b86c6a2105b6a72b06d26412cf0384cd2b66262d92491d01ed7f926671bfa267",
        "sha256:125aadb3053d553a269e3dda1ac4b88a734825c319ac5c4e68c14afb49776906"
  ]
[..]
```
```bash
docker inspect image_1
```
```
[..]
  "Layers": [
        "sha256:219a998c60509502b47b97f1158067d5dd62640d2d689560d32cfd5594f6bc40",
        "sha256:8258db9b59a3c0bdb28a9f64841c53636ec5646c60a16867e4e7327b64b69482",
        "sha256:b86c6a2105b6a72b06d26412cf0384cd2b66262d92491d01ed7f926671bfa267",
        "sha256:125aadb3053d553a269e3dda1ac4b88a734825c319ac5c4e68c14afb49776906",
        "sha256:a1780beb3f2c7c8c9631bd8b6ac4053bccab11cc6f463e8a64f091f766d2be47",
        "sha256:ce367af90a0eed200a03178ab48c0fb703de5f7657b0f0c010a484ff06b5dce7",
        "sha256:b8e73a9933a8ab4c8569c75055354aed54e344980a0d7c10cd342b8b48cbe24f"
  ]
[..]
```
```bash
docker inspect image_2
```
```
[..]
  "Layers": [
        "sha256:219a998c60509502b47b97f1158067d5dd62640d2d689560d32cfd5594f6bc40",
        "sha256:8258db9b59a3c0bdb28a9f64841c53636ec5646c60a16867e4e7327b64b69482",
        "sha256:b86c6a2105b6a72b06d26412cf0384cd2b66262d92491d01ed7f926671bfa267",
        "sha256:125aadb3053d553a269e3dda1ac4b88a734825c319ac5c4e68c14afb49776906",
        "sha256:9802b3f71028921af489b6d3f2b3c17ecc09e0ebe2e90e812015958770370074",
        "sha256:39bb5527ffaae0e826a724f9dd5ed763387dc55038c03bc4434d25f7c0256bae",
        "sha256:c1455dfeb2a280f7a839f95fc6828772b63690a13266c4d9a1114df30de849e3"
  ]
[..]
```