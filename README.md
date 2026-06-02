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
- Isolatie is minder/niet aanwezig

---

# Wat is een Docker Image?

Een image is:
> Een blueprint (template) voor containers, deels vergelijkbaar met een virtuele harddisk.

Bestaat uit:
- Layers (immutable)
- Base image (bv. Debian, Alpine)
- Applicatie code
- Dependencies

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
