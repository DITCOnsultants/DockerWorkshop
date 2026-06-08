# Pipelines
Om docker images automatisch te laten bouwen kunnen we gebruik maken van een CI/CD pipeline.

Omdat het handig kan zijn een self-hosted omgeving hiervoor te draaien hebben we een project klaargezet waarmee je in enkele minuten een volledige CI/CD omgeving kan opzetten.

* Git server
* Pipeline runner
* Package repository
* Clone van deze workshop

---

# Forgejo
We hebben gekozen voor het opensource project Forgejo. Dit is een fork van Gitea en is een populair stuk software met veel mogelijkheden. Voor het deel van de pipelines gebruikt men dezelfde code als voor Github Actions. Dit zorgt ervoor dat je toegang hebt tot een enorme bibliotheek aan mogelijkheden.

---

## Installatie
In de hoofdmap staat de map 'forgejo'. Hierin zijn alle componenten terug te vinden welke nodig zijn voor de installatie. We hebben een README.md waarin je de details van de installatie terug kan vinden, iedere stap die nodig is om tot een functionele omgeving te komen.

Om ook de snelheid erin te houden is er een 2e optie, de `tldr.sh`. Als je deze uitvoert zal hij alles automatisch in orde maken voor je:

![Forgejo installatie](./forgejo.gif)

Tijdens de installatie krijg je een gegenereerd forgejo-admin wachtwoord terug. Deze is later nog op te zoeken in het bestand `.env` in de map vanuit waar je het `tldr.sh` script start.

Dit wachtwoord is niet bijzonder sterk. Mocht je overwegen om Forgejo op een meer bereikbare plek te draaien kies dan vooral voor een complexer wachtwoord met 2FA.

---

# Automatisch bouwen

Stel je hebt een mooie officiele docker image gevonden, maar die voldoet net niet aan je wensen. Je bent nu in staat om een Dockerfile te maken om deze image als basis te nemen en je eigen aanpassingen erop los te laten.

Dan komt er een update van het basis image... Of je bent je aanpassingen aan het optimaliseren en wil weer een nieuwe image bouwen...

Zou het niet mooi zijn als dit helemaal automagisch kan :D

---

## Het pipeline project

### Variabelen en secrets
We moeten in Forgejo een variabele instellen:

* log in op de webinterface en ga naar site beheer (rechts-boven op je user-icon -> Site beheer)
* Links in het menu klik je op Actions -> Variabelen
* Maak een variabele aan met de naam "DOCKER_REGISTRY" en als inhoud het IP plus de poort van je Forgejo installatie. In mijn geval nu '10.4.18.252:3000'

Vervolgens moeten we de secrets opgeven om in te kunnen loggen. Secrets kan je niet globaal aanmaken, die maak je per repository aan, per organisatie, of voor alle repo's van een gebruiker.

* Klik bovenin op 'Verkennen' gevolgd door 'Gebruikers' en tenslotte klik je op 'forgejo-admin'. Indien je de repositories onder een organisatie hebt hangen, moet je daar op klikken.
* Klik links onder het user-icon op de [...] knop en kies voor 'Profiel bewerken'.
* Vervolgens klik je links in het menu op 'Actions' en dan op 'Geheimen'
* Maak 2 secrets aan, DOCKER_USER met de waarde forgejo-admin en DOCKER_PASS met het wachtwoord van het admin account.

---

### Nieuwe repository
* Klik rechts-boven op het plusje en maak een nieuwe repository, kies als naam bijvoorbeeld `dockertestimage`
* Maak in deze nieuwe repo 2 bestanden aan:
Dockerfile 
```Dockerfile
FROM linuxserver/code-server
RUN groupadd docker --gid 103
RUN usermod -a -G docker abc
RUN apt update && apt install -y docker-cli
```

En .forgejo/workflows/build.yaml
```yaml
---
name: build Docker image
run-name: New Docker image
on:
  push:
  schedule:
    - cron: '0 0 8 * *'

env:
  image_org: forgejo-admin  # Onder deze naam staat de repo
  image_name: dockertestimage  # Deze naam krijgt de image
  image_tag: v1  # Deze tag geven we mee
  # Verder hebben we een username en password nodig
  # Deze stellen we als 'secret' in bij de instellingen van de actions

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: docker/login-action@v4
        name: Docker login
        with:
          username: ${{ secrets.DOCKER_USER }}
          password: ${{ secrets.DOCKER_PASS }}
          registry: ${{ vars.DOCKER_REGISTRY }}
      - uses: actions/checkout@v4
      - name: Test build
        if: forgejo.ref != 'refs/heads/master' && forgejo.ref != 'refs/heads/main'
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ vars.DOCKER_REGISTRY }}/${{ env.image_org}}/${{ env.image_name}}:testing-${{ env.FORGEJO_REF_NAME}}
      - name: Prod build
        if: forgejo.ref == 'refs/heads/master' || forgejo.ref == 'refs/heads/main'
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ vars.DOCKER_REGISTRY }}/${{ env.image_org}}/${{ env.image_name}}:${{ env.image_tag}}
```
Nadat je die 2e file gemaakt hebt zal Forgejo automatisch de Actions gaan starten. Deze pipeline gaat dan voor je een docker image bouwen en zal deze als package toevoegen aan de repository.

Bij iedere nieuwe push naar deze repo zal hij een nieuwe image bouwen. Als de push in main/master zit; zal hij ook een nieuwe image in de registry plaatsen. Daarnaast zal hij iedere maand op de 8e een nieuwe build proberen. Dit doen we om upstream updates tenminste 1x per maand binnen te halen.

---

### Container maken
Door gebruik te maken van de `docker-compose.yml` in deze map kan je een container maken op basis van de zojuist gemaakte image. Pas voor je de container maakt, wel even de image naam aan. De placeholder `mijnip` moet je even vervangen met het IP van je VM zodat de image kan worden gevonden.

```bash
eric@testlab:/opt/workshop/my_first_pipeline$ docker-compose up -d
[+] Running 1/1
 ✔ Container vscode  Started
 ```

 We hebben nu de code-server image voorzien van de Docker cli tools. Daarmee is het mogelijk om in je webbrowser: [http://mijnip:8443/](http://mijnip:8443/) visual-studio code te gebruiken met in de terminal de mogelijkheid om alle docker commando's te gebruiken... 

![VScode](./vscode%20container.png)

---

## Pipeline syntax
Forgejo, Gitea en Github gebruiken allemaal dezelfde `Actions` syntax. Hiervoor maak je een submap in je repository genaamd: '.github', '.gitea' of '.forgejo' (afhankelijk van het gekozen product) met daarin een map 'workflows'.

YAML bestanden in deze workflows map worden geinterpreteerd als pipeline beschrijvingen.

Hier breken we de eerder genoemde YAML nog eens op om te beschrijven wat het allemaal doet.

In dit deel wordt de naam en run-name ingesteld. Dit is zichtbaar in het 'Actions' gedeelde nadat de pipeline heeft gedraait.
```yaml
name: build Docker image
run-name: New Docker image
```

In dit deel wordt bepaald *wanneer* de pipeline moet starten. Zie hiervoor ook: [de documentatie](https://forgejo.org/docs/latest/user/actions/reference/#on)
```yaml
on:
  push:
  schedule:
    - cron: '0 0 8 * *'
```

Vervolgens zetten we een aantal variabelen in de 'environment' zodat we deze later kunnen hergebruiken.
```yaml
env:
  image_org: forgejo-admin  # Onder deze naam staat de repo
  image_name: dockertestimage  # Deze naam krijgt de image
  image_tag: v1  # Deze tag geven we mee
  # Verder hebben we een username en password nodig
  # Deze stellen we als 'secret' in bij de instellingen van de actions
```

Een pipeline bevat altijd 1 of meerdere jobs. Binnen een job kan je meerdere taken (steps) uitvoeren, je kan ook meerdere jobs beschrijven die ieder 1 of meerdere taken bevatten.

*Let op:* Iedere job krijgt zijn eigen container. Meerder steps worden achter elkaar uitgevoerd maar jobs kunnen ook parallel lopen. In een productie omgeving met meerdere runners kunnen jobs ook op verschillende systemen tegelijk draaien.

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest  # Dit is een label, zie RUNNER_LABELS in de .env van Forgejo
    # container: dockerimagename/here:latest  # Het is ook mogelijk expliciet een container image op te geven
    steps:
```

We gebruiken in deze steps diverse externe bibliotheken. Forgejo zal deze automatisch ophalen van github of de forgejo repo's.
* [docker/login-action](https://code.forgejo.org/docker/login-action/)
* [actions/checkout](https://code.forgejo.org/actions/checkout/)
* [docker/build-push-action](https://code.forgejo.org/docker/build-push-action/)

```yaml
      - uses: docker/login-action@v4
        name: Docker login
        with:
          username: ${{ secrets.DOCKER_USER }}
          password: ${{ secrets.DOCKER_PASS }}
          registry: ${{ vars.DOCKER_REGISTRY }}
      - uses: actions/checkout@v4
```

Ook kunnen we voor een step een `if` statement gebruiken. Indien we niet in de main/master branch zitten, publiceren we enkel een test image.
```yaml
      - name: Test build
        if: forgejo.ref != 'refs/heads/master' && forgejo.ref != 'refs/heads/main'
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ vars.DOCKER_REGISTRY }}/${{ env.image_org}}/${{ env.image_name}}:testing-${{ env.FORGEJO_REF_NAME}}
      - name: Prod build
        if: forgejo.ref == 'refs/heads/master' || forgejo.ref == 'refs/heads/main'
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ vars.DOCKER_REGISTRY }}/${{ env.image_org}}/${{ env.image_name}}:${{ env.image_tag}}
```
