# OS Installatie

## Taal en Regio
De OS installatie is vrij basis, we kiezen heel bewust voor een Engelse installatie met als location "Europe / Netherlands". Dit zorgt ervoor dat de tijdzone goed staat, een lokale mirror gebruikt wordt en we niet een Nederlands OS hebben.

## Identiteit
We kiezen een zinnige hostname en domain name.

We stellen een root wachtwoord in en maken een 1e normale systeem user. In dit geval `workshop`.

## Disk indeling
We laten de disk partities helemaal standaard en moeten enkel even bevestigen dat we de disk overschrijven.

## Software selectie
We kiezen ervoor geen extra CD in te voeren en kiezen vervolgens de defaults om een Nederlandse mirror te gebruiken.

Omdat deze workshop geen grafische desktop nodig heeft, deselecteren we de Desktop environment en GNOME.

Indien gewenst kan je hier openssh inschakelen. Dan is de VM ook makkelijker over te nemen via een SSH client. Dit is later handig als je wil copy/pasten van en naar de VM.

## Boot loader
Voor het installeren van Grub moeten we expliciet de disk selecteren

## Klaar
Tenslotte wordt het systeem herstart (eventueel de installatie ISO even verwijderen?) en kan je inloggen.

# Video
![Zie ook de MKV om op je gemak te kunnen kijken (mogelijkheid om te pauzeren)](./Debian%2013%20installatie.gif)