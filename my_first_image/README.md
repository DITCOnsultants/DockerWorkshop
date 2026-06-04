Doel:
- Hoe maak ik een eigen image?
- Wat kan ik met een eigen image?


1. **Maak een eigen image:**
   ```bash
   docker build . -t testimage01
   ```

| Parameter | Doel |
| :--- | :--- |
| **`docker build`** | Bouw een nieuwe image |
| **`.`** | Geeft de locatie aan van de 'Dockerfile' |
| **`-t`** | Geef de image een tag/naam |

2. **Wat doet een Dockerfile?**
   Iedere regel in een Dockerfile resulteert normaal gesproken in een extra layer.
   Te beginnen met een *FROM* (importeer een bestaande image) en gevolgd door allerlei 
   bewerkingen om bestanden te kopieren, commando's uit te voeren etc.
```dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```
   In dit geval nemen we de nginx image uit de vorige opdracht en kopieren de index.html naar de webmap.
   