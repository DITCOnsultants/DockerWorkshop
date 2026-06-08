# Pipelines
Om docker images automatisch te laten bouwen kunnen we gebruik maken van een CI/CD pipeline.

Omdat het handig kan zijn een self-hosted omgeving hiervoor te draaien hebben we een project klaargezet waarmee je in enkele minuten een volledige CI/CD omgeving kan opzetten.

* Git server
* Pipeline runner
* Clone van deze workshop

# Forgejo
We hebben gekozen voor het opensource project Forgejo. Dit is een fork van Gitea en is een populair stuk software met veel mogelijkheden. Voor het deel van de pipelines gebruikt men dezelfde code als voor Github Actions. Dit zorgt ervoor dat je toegang hebt tot een enorme bibliotheek aan mogelijkheden.

## Installatie
In de hoofdmap staat de map 'forgejo'. Hierin zijn alle componenten terug te vinden welke nodig zijn voor de installatie. We hebben een README.md waarin je de details van de installatie terug kan vinden, iedere stap die nodig is om tot een functionele omgeving te komen.

Om ook de snelheid erin te houden is er een 2e optie, de `tldr.sh`. Als je deze uitvoert zal hij alles automatisch in orde maken voor je:

![Forgejo installatie](./forgejo.gif)

Tijdens de installatie krijg je een gegenereerd forgejo-admin wachtwoord terug. Deze is later nog op te zoeken in het bestand `.env` in de map vanuit waar je het `tldr.sh` script start.

Dit wachtwoord is niet bijzonder sterk. Mocht je overwegen om Forgejo op een meer bereikbare plek te draaien kies dan vooral voor een complexer wachtwoord met 2FA.

