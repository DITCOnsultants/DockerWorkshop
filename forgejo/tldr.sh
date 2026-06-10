#!/bin/bash

if [[ $EUID -ne 0 ]]
then
  echo "Please run as root"
  exit 1
fi

useradd --system --no-create-home --shell /sbin/nologin forgejo
usermod -aG docker forgejo

cp .env.example .env

sed -i "s/fill_with_forgejo_uid/$(id -u forgejo)/" .env
sed -i "s/fill_with_forgejo_gid/$(id -g forgejo)/" .env

IPADDR=`hostname -I | awk '{ print $1 }'`
sed -i "s|localhost|$IPADDR|g" .env
sed -i "s/fill_with_docker_gid/$(getent group docker | cut -d: -f3)/" .env

sed -i "0,/changeme_generate_with_openssl_rand_hex_32/{s/changeme_generate_with_openssl_rand_hex_32/$(openssl rand -hex 32)/}" .env
sed -i "0,/changeme_generate_with_openssl_rand_hex_32/{s/changeme_generate_with_openssl_rand_hex_32/$(openssl rand -hex 32)/}" .env

PASS=`openssl rand -hex 4`

sed -i "s/changeme/$PASS/" .env

echo "Initial admin password: $PASS"

# 6. Create the data directories owned by the forgejo system account
mkdir -p /opt/docker/forgejo/data
mkdir -p /opt/docker/forgejo/runner
chown -R forgejo:forgejo /opt/docker/forgejo

echo "Starting containers..."
if command -v docker-compose
then
  docker-compose up -d
else
  docker compose up -d
fi

echo "Done: go to http://$IPADDR:3000 and login using forgejo-admin / $PASS"
