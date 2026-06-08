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

## Volgorde en efficiency
Zoals zojuist vermeld zorgt iedere regel in een Dockerfile voor een nieuwe laag. Deze lagen worden allemaal opgeslagen aan de hand van de hash van de laag.

Stel je hebt 10 images allemaal gebaseerd op dezelfde basis image; deze wordt door deze structuur maar 1 keer opgeslagen. Een image is immers immutible en wordt opgeslagen op basis van de hash. Een goede vorm van deduplicatie.

Stel je nu voor dat je de volgende 2 Dockerfiles hebt:

Image 1
```Dockerfile
FROM python:3-slim                      # Basis image op basis van Python
RUN pip3 install --no-cache-dir flask   # Installeer een Python module genaamd: flask
RUN useradd nonroot                     # Maak een user aan
COPY ./testscript1.py /app/             # Copieer het testscript in de image
USER nonroot                            # Verander de actieve user
CMD ["/app/testscript1.py"]             # Het commando om te draaien bij het starten van de container
```

Image 2
```Dockerfile
FROM python:3-slim                      # Basis image op basis van Python
RUN pip3 install --no-cache-dir pandas  # Installeer een andere Python module genaamd: pandas
RUN useradd nonroot                     # Maak een user aan
COPY ./testscript2.py /app/             # Copieer het testscript in de image
USER nonroot                            # Verander de actieve user
CMD ["/app/testscript2.py"]             # Het commando om te draaien bij het starten van de container
```

Beide docker images gebruiken dezelfde basis image, deze ruimte wordt maar 1 keer gebruikt (zowel op disk als eventueel in een registry).

Regel 2 is echter anders voor beide images. Dit 

Door bijvoorbeeld de installatie van de Python module naar beneden te verplaatsen