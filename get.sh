#!/bin/bash

## Welkom bij de Docker workshop.
# Dit script installeert een aantal requirements 
# en zet vervolgens een kopie van de repo klaar.

# Usage: wget -O - https://docker.frotmail.nl/ | bash

# Controleer eerst of we de juiste rechten hebben om zaken te installeren:
if [[ $EUID -ne 0 ]]
then
  echo "Please run this script as root!"
  exit 1
fi
echo "Installing required packages..."
apt install -y \
  git \
  ansible 1> /dev/null

# Geef de normale user docker rechten en clone de repo
echo "Give regular user docker permissions"
TARGET_USER=$(id -nu 1000 2>/dev/null)
if [ -z "$TARGET_USER" ]; then
    echo "Error: No user found with UID 1000."
    exit 1
fi
usermod -a -G docker "$TARGET_USER"
mkdir /opt/workshop
chown 1000:1000 /opt/workshop

echo "Switching to user $TARGET_USER"
su - "$TARGET_USER" << EOF
  echo "Cloning repo into /opt/workshop" 
  cd /opt/
  git clone https://github.com/DITCOnsultants/DockerWorkshop.git workshop
EOF