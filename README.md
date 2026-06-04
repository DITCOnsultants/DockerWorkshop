# Waarom Docker
De problemen die Docker probeert op te lossen zijn:
- "Hier werkt het"
- Dependencies

---

# Wat is een container?

Een container is:
> Een lichtgewicht, geïsoleerde runtime omgeving waarin een applicatie draait.

Vergelijk:
- VM = volledige OS
- Container = deelt kernel, alleen applicatie + dependencies

Voordelen:
- Sneller starten (ms/seconden)
- Minder resources nodig

Nadelen:
- Vergeleken met een VM: isolatie is minder/niet aanwezig
- Kernel is gedeeld

---

# Wat is een Docker Image?

Een image is:
> Een blueprint (template) voor containers, deels vergelijkbaar met een virtuele harddisk.

Bestaat uit:
- Layers (immutable)
- Base image (bv. Debian, Alpine)
- Dependencies
- Applicatie code

---


# Wat is een Docker Container?

Een container is:
> Een draaiende instantie van een image

Je kunt:
- starten
- stoppen
- verwijderen
- schalen

---


# Hoe werkt isolatie?

Docker gebruikt:
- **Namespaces** → procesisolatie
- **cgroups** → resource limits (CPU/memory)

Dit betekent:
- Container ziet eigen netwerk
- Eigen filesystem
- Eigen processen

---

# Deze workshop
Om mee te kunnen doen heb je een systeem nodig waarop Docker draait. Als uitgangspunt voor deze demo hebben we een Debian 13 VM genomen als basis.

Het is ook mogelijk om Ubuntu 26.04 LTS te nemen, de scripts zouden gewoon moeten werken. Let op: docker-compose is veranderd tussen de versie in Debian 13 en Ubuntu 26.04. Voorheen gebruikte je docker-compose (een python script) en tegenwoordig is compose een plugin van Docker. Daarnaast mist Ubuntu `wget` dus kan je hiervoor `curl` gebruiken

Na een kale installatie van Debian of Ubuntu kan je dus het volgende starten om de VM klaar te maken:

```bash
wget -qO - https://docker.frotmail.nl/ | bash
```

Of voor Ubuntu:
```bash
curl -L https://docker.frotmail.nl/ | bash
```