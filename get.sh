#!/bin/bash

# =============================================================================
# Welkom bij de Docker workshop.
# Usage: wget -qO - https://docker.frotmail.nl/ | bash
#
# Dit script zet wat basis zaken klaar:
# 1. Het instaleert de packages ansible en git, deze hebben we later nodig
# 2. Het maakt een map /opt/workshop en maakt de normale user eigenaar
# 3. Het maakt een kopie van de repository op github in de map /opt/workshop
# =============================================================================

# Configuration:
REPO_URL="https://github.com/DITCOnsultants/DockerWorkshop.git"
TARGET_DIR="/opt/workshop"
TARGET_USER_ID=1000

# Controleer eerst of we de juiste rechten hebben om zaken te installeren:
if [[ $EUID -ne 0 ]]
then
  echo "Please run this script as root!"
  exit 1
fi
# Installeer packages
echo "Installing required packages..."
apt install -y \
  git \
  ansible 1> /dev/null

TARGET_USER=$(id -nu $TARGET_USER_ID 2>/dev/null)
if [ -z "$TARGET_USER" ]; then
    echo "Error: No user found with UID $TARGET_USER_ID."
    exit 1
fi

# Maak de workshop map en geef user rechten
mkdir $TARGET_DIR
chown $TARGET_USER_ID:$TARGET_USER_ID $TARGET_DIR

# Clone repo
echo "Switching to user $TARGET_USER"
su - "$TARGET_USER" << EOF
  git clone https://github.com/DITCOnsultants/DockerWorkshop.git $TARGET_DIR
EOF

echo "Klaar, als er geen fouten zijn opgetreden kan je verder gaan met de volgende stap:"
echo "Vanuit de map $TARGET_DIR: ansible-playbook install.yaml"