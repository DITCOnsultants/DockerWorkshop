# Watchtower
Auto-updates voor alle containers!

Watchtower kijkt per container of er upstream een nieuwere image beschikbaar is. Zo ja dan download hij de nieuwe image en vervangt de draaiende container met een nieuwe.

Er zijn containers die hier niet zo goed mee om kunnen gaan maar het gros gaat prima!

Er zijn een hoop opties om mee te geven:
* Notificaties bij updates
* CRON schedule
* Containers uitzonderen

Voor deze en meer zie [de documentatie](https://watchtower.nickfedor.com/)

## Private registries
Als je images draait vanuit een private registry waarvoor je in moet loggen dien je een docker config.json mee te geven. 

Voer daarvoor op je host een docker login uit en koppel die json binnen je container (zie onderste regel van de docker-compose, pas wel even het pad aan naar de juiste user)
