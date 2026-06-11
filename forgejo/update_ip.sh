#!/bin/bash
if [[ $EUID -ne 0 ]]
then
  echo "Please run as root"
  exit 1
fi

cd /opt/workshop/forgejo

OLDIP=`cat .env | grep FORGEJO_DOMAIN | cut -d '=' -f2`
IPADDR=`hostname -I | awk '{ print $1 }'`

# Update de .env zodat het IP daar wordt bijgewerkt
sed -i "s|$OLDIP|$IPADDR|g" .env

# Updat de docker config
ansible-playbook /opt/workshop/install.yaml

if command -v docker-compose
then
  docker-compose up -d
else
  docker compose up -d
fi

echo "LET OP: Tijdens de workshop hebben we in Forgejo ook een DOCKER_REGISTRY variabele gemaakt, deze dien je ook bij te werken naar $IPADDR:3000"