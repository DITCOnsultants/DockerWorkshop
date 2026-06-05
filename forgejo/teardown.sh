#!/bin/bash

if [[ $EUID -ne 0 ]]
then
  echo "Please run as root"
  exit 1
fi

echo "Stopping containers..."
if command -v docker-compose
then
  docker-compose down
else
  docker compose down
fi

echo "Removing user..."
userdel forgejo

echo "Removing data..."
rm -R /opt/docker/forgejo
