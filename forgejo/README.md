# Forgejo — automated Docker deployment

Fully automated Forgejo deployment with:
- Admin user creation
- Optionally create and clone an existing repo defined in SEED_REPO_URL
- Actions enabled
- Runner registered and daemonised

## Quick start

```bash
# 1. Create a dedicated system account for Forgejo (no login, no home directory)
#    and add it to the docker group so the Actions runner can reach the Docker socket
sudo useradd --system --no-create-home --shell /sbin/nologin forgejo
sudo usermod -aG docker forgejo

# 2. Clone / copy this directory, then:
cp .env.example .env

# 3. Fill in the Forgejo system account UID, GID, and the Docker group GID
sed -i "s/fill_with_forgejo_uid/$(id -u forgejo)/" .env
sed -i "s/fill_with_forgejo_gid/$(id -g forgejo)/" .env
sed -i "s/fill_with_docker_gid/$(getent group docker | cut -d: -f3)/" .env

# 4. Generate secret keys (run twice — there are two placeholders)
sed -i "0,/changeme_generate_with_openssl_rand_hex_32/{s/changeme_generate_with_openssl_rand_hex_32/$(openssl rand -hex 32)/}" .env
sed -i "0,/changeme_generate_with_openssl_rand_hex_32/{s/changeme_generate_with_openssl_rand_hex_32/$(openssl rand -hex 32)/}" .env

# 5. Set your admin password and domain
$EDITOR .env
# Required: ADMIN_PASSWORD — everything else has a working default

# 6. Create the data directories owned by the forgejo system account
mkdir -p /opt/docker/forgejo/data
mkdir -p /opt/docker/forgejo/runner

sudo chown forgejo:forgejo -R /opt/docker/forgejo

# 7. Deploy
sudo docker compose up -d

# 8. Show logs
sudo docker compose logs
```

# 9. Reset the environment
```bash
# remove containers
sudo docker compose down
# remove data
sudo rm -rf /opt/docker/forgejo
# precreate volumes with permissions
mkdir -p /opt/docker/forgejo/data
mkdir -p /opt/docker/forgejo/runner
sudo chown forgejo:forgejo -R /opt/docker/forgejo
# start containers
sudo docker compose up
```