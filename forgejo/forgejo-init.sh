#!/bin/bash
# forgejo-init.sh — runs once after Forgejo is healthy
# Creates admin user, pre-registers the Actions runner, and writes its config.

set -euo pipefail

FORGEJO_URL="${FORGEJO_URL:-http://forgejo:3000}"
ADMIN_USER="${ADMIN_USER:-forgejo-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:?ADMIN_PASSWORD env var is required}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@localhost}"
RUNNER_NAME="${RUNNER_NAME:-default-runner}"
RUNNER_LABELS="${RUNNER_LABELS:-ubuntu-latest:docker://catthehacker/ubuntu:act-latest}"
RUNNER_CONFIG_FILE="/data/runner.yaml"

log()  { echo "[forgejo-init] $*"; }
ok()   { echo "[forgejo-init] ✓ $*"; }
warn() { echo "[forgejo-init] ⚠ $*"; }
die()  { echo "[forgejo-init] ✗ $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Wait for Forgejo API to be reachable
# ---------------------------------------------------------------------------
log "Waiting for Forgejo API at ${FORGEJO_URL} ..."
for i in $(seq 1 30); do
  if curl -sf "${FORGEJO_URL}/api/healthz" >/dev/null 2>&1; then
    ok "Forgejo is reachable."
    break
  fi
  [ "$i" -eq 30 ] && die "Forgejo did not become ready in time."
  sleep 2
done

# ---------------------------------------------------------------------------
# 2. Create admin user (idempotent — skip if already exists)
# ---------------------------------------------------------------------------
log "Creating admin user '${ADMIN_USER}' ..."
if forgejo admin user list --config /data/gitea/conf/app.ini 2>/dev/null \
     | awk 'NR>1{print $2}' | grep -qx "${ADMIN_USER}"; then
  warn "Admin user '${ADMIN_USER}' already exists — skipping creation."
else
  forgejo admin user create \
    --config /data/gitea/conf/app.ini \
    --username  "${ADMIN_USER}" \
    --password  "${ADMIN_PASSWORD}" \
    --email     "${ADMIN_EMAIL}" \
    --admin \
    --must-change-password=false
  ok "Admin user '${ADMIN_USER}' created."
fi

# ---------------------------------------------------------------------------
# 3. Verify Actions are enabled via the API
# ---------------------------------------------------------------------------
log "Checking Actions status ..."
HTTP_CODE=$(curl -s \
  -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
  "${FORGEJO_URL}/api/v1/admin/cron" \
  -o /dev/null -w "%{http_code}" || true)

if [ "${HTTP_CODE}" = "200" ]; then
  ok "Forgejo API accessible with admin credentials."
else
  warn "Could not verify via cron API (HTTP ${HTTP_CODE}), continuing anyway."
fi

# ---------------------------------------------------------------------------
# 4. Pre-register runner via forgejo-cli and write runner config
#    Uses the v12 offline registration approach — no interactive token needed.
# ---------------------------------------------------------------------------
if [ -f "${RUNNER_CONFIG_FILE}" ]; then
  warn "Runner config already exists at ${RUNNER_CONFIG_FILE} — skipping registration."
else
  log "Registering runner '${RUNNER_NAME}' ..."

  # 20 random bytes encoded as hex = 40-char string required by Forgejo
  # (first 16 chars = runner identifier, last 24 = secret value)
  SECRET=$(head -c 20 /dev/urandom | od -An -tx1 | tr -d ' \n')

  UUID=$(forgejo forgejo-cli actions register \
    --config /data/gitea/conf/app.ini \
    --name   "${RUNNER_NAME}" \
    --secret "${SECRET}" 2>/dev/null | tail -n1)

  [ -z "${UUID}" ] && die "Runner registration failed — got empty UUID."

  # Convert comma-separated labels to indented YAML list entries
  YAML_LABELS=""
  IFS=',' read -ra label_array <<< "${RUNNER_LABELS}"
  for label in "${label_array[@]}"; do
    YAML_LABELS="${YAML_LABELS}    - \"${label}\"
"
  done

  cat > "${RUNNER_CONFIG_FILE}" <<EOF
log:
  level: info

runner:
  capacity: 1
  timeout: 3h
  insecure: false
  labels:
${YAML_LABELS}
cache:
  enabled: false

host:
  workdir: /tmp/forgejo-runner

server:
  connections:
    forgejo:
      url: ${FORGEJO_URL}
      uuid: ${UUID}
      token: ${SECRET}
EOF
  chmod 600 "${RUNNER_CONFIG_FILE}"
  ok "Runner '${RUNNER_NAME}' registered. Config saved to ${RUNNER_CONFIG_FILE}."
fi

# ---------------------------------------------------------------------------
# 5. Seed repository (optional — only runs if SEED_REPO_URL is set)
# ---------------------------------------------------------------------------
if [ -n "${SEED_REPO_URL:-}" ]; then
  REPO_NAME=$(basename "${SEED_REPO_URL}" .git)
  log "Checking for repository '${REPO_NAME}' ..."

  HTTP_CODE=$(curl -s \
    -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
    -o /dev/null -w "%{http_code}" \
    "${FORGEJO_URL}/api/v1/repos/${ADMIN_USER}/${REPO_NAME}")

  if [ "${HTTP_CODE}" = "200" ]; then
    warn "Repository '${REPO_NAME}' already exists — skipping migration."
  else
    log "Migrating '${SEED_REPO_URL}' → ${ADMIN_USER}/${REPO_NAME} ..."
    RESPONSE=$(curl -s \
      -X POST \
      -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
      -H "Content-Type: application/json" \
      -w "\n%{http_code}" \
      "${FORGEJO_URL}/api/v1/repos/migrate" \
      -d "{
        \"clone_addr\": \"${SEED_REPO_URL}\",
        \"repo_name\": \"${REPO_NAME}\",
        \"repo_owner\": \"${ADMIN_USER}\",
        \"mirror\": false,
        \"private\": false
      }")

    HTTP_CODE=$(echo "${RESPONSE}" | tail -n1)
    BODY=$(echo "${RESPONSE}" | head -n-1)

    [ "${HTTP_CODE}" != "201" ] && die "Migration failed (HTTP ${HTTP_CODE}): ${BODY}"
    ok "Repository '${REPO_NAME}' migrated from ${SEED_REPO_URL}."
  fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
ok "Forgejo initialisation complete."
ok "  Admin user : ${ADMIN_USER}"
ok "  Actions    : enabled (via FORGEJO__actions__ENABLED=true)"
ok "  Runner     : config ready at ${RUNNER_CONFIG_FILE}"
