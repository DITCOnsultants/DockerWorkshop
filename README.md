# Waarom Containers

De problemen die Docker probeert op te lossen zijn:

* **"Hier werkt het"**: Doordat de applicatie overal in dezelfde context draait gedraagd het zich consistenter.
* **Depencencies**: Als er op 1 systeem door diverse applicaties verschillende versies nodig zijn van een bibliotheek zorgt Docker ervoor dat deze versies onderling elkaar niet bijten.
* **Efficiency**: Omdat we geen VM's draaien, maar enkel processen in eigen namespaces; hebben we minder resources nodig en is er toch een mate van scheiding tussen de applicaties.

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

Containers draaien doorgaans op een platform of een zogenaamde container runtime. Dit zijn enkele voorbeelden hiervan:

* **containerd**: De industriestandaard. Het is een minimalistische runtime die als fundament dient voor zowel 
Docker als Kubernetes.
* **Podman**: Een "daemonless" alternatief voor Docker. Het biedt vergelijkbare functionaliteit, maar zonder een 
centraal proces dat constant met root-rechten op de achtergrond draait.
* **LXC (Linux Containers)**: Richt zich op *system containers*. Waar Docker zich focust op één enkel proces per 
container, gedraagt LXC zich meer als een lichtgewicht virtuele machine met een volledige OS-stack.

Kubernetes, Docker en Docker Swarm zijn tools (orchestrators) die zorgen voor het beheer van de containers. Waarbij Docker een eenvoudige tool is om op 1 host te werken en de andere 2 complete clusters kunnen beheren en meer...

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

Na een kale installatie van Debian of Ubuntu kan je het volgende starten om de VM klaar te maken:

Als root:
```bash
wget -qO - https://docker.frotmail.nl/ | bash
```

Of voor Ubuntu:
```bash
curl -L https://docker.frotmail.nl/ | bash
```

Na deze 1e stap is er een map /opt/workshop gemaakt op het Linux systeem. Hierin zit een Ansible playbook die de rest in orde maakt:

```bash
cd /opt/workshop
ansible-playbook install.yaml
```

Daarna gaan we naar de 1e opdracht: my_first_container