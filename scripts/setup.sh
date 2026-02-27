#!/usr/bin/env bash
# ============================================================
# Media Stack - Setup Script
# Éénmalig uitvoeren vóór de eerste deploy
# Gebruik: bash setup.sh
# ============================================================

set -euo pipefail

# --- Kleuren voor output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok()   { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "=============================================="
echo "  Media Stack - Setup"
echo "=============================================="
echo ""

# --- Laad .env als die bestaat ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [ ! -f "$ENV_FILE" ]; then
  log_err ".env bestand niet gevonden op: $ENV_FILE"
  log_warn "Kopieer .env.example naar .env en vul de waarden in"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"
log_ok ".env geladen"

# --- Controleer of volumes gemount zijn ---
check_volume() {
  local path="$1"
  local name="$2"

  if [ ! -d "$path" ]; then
    log_err "Volume pad bestaat niet: $path ($name)"
    log_warn "Zorg dat het volume gemount is voordat je dit script uitvoert"
    exit 1
  fi

  # Controleer of het geen lege systeemmap is die toevallig bestaat
  if ! touch "$path/.write_test" 2>/dev/null; then
    log_err "Pad is niet schrijfbaar: $path ($name)"
    exit 1
  fi
  rm -f "$path/.write_test"
  log_ok "Volume beschikbaar en schrijfbaar: $path"
}

echo ""
echo "--- Volumes controleren ---"
check_volume "$MEDIA_PATH"  "Media"
check_volume "$DOCKER_PATH" "Docker config"
check_volume "$DB_PATH"     "Databases SSD"

# --- Maak mappen aan ---
echo ""
echo "--- Mappen aanmaken ---"

DIRS=(
  # Media mappen
  "$MEDIA_PATH/Download/complete"
  "$MEDIA_PATH/Download/incomplete"
  "$MEDIA_PATH/Movie"
  "$MEDIA_PATH/TV"
  "$MEDIA_PATH/Music"
  "$MEDIA_PATH/Books"

  # Config mappen per container
  "$DOCKER_PATH/sabnzbd/config"
  "$DOCKER_PATH/prowlarr/config"
  "$DOCKER_PATH/sonarr/config"
  "$DOCKER_PATH/radarr/config"
  "$DOCKER_PATH/lidarr/config"
  "$DOCKER_PATH/bazarr/config"
  "$DOCKER_PATH/jellyfin/config"
  "$DOCKER_PATH/jellyseerr/config"
  "$DOCKER_PATH/recyclarr/config"

  # Database mappen
  "$DB_PATH/jellyfin"
)

for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    log_warn "Bestaat al (overgeslagen): $dir"
  else
    mkdir -p "$dir"
    log_ok "Aangemaakt: $dir"
  fi
done

# --- Stel permissions in ---
echo ""
echo "--- Permissions instellen ---"

if [ -n "${PUID:-}" ] && [ -n "${PGID:-}" ]; then
  chown -R "$PUID:$PGID" "$MEDIA_PATH" "$DOCKER_PATH" "$DB_PATH" 2>/dev/null \
    && log_ok "Permissions ingesteld voor PUID=$PUID PGID=$PGID" \
    || log_warn "Kon permissions niet instellen (mogelijk geen root). Controleer handmatig."
else
  log_warn "PUID/PGID niet gevonden in .env, permissions overgeslagen"
fi

# --- Klaar ---
echo ""
echo "=============================================="
log_ok "Setup voltooid!"
echo ""
echo "Volgende stap:"
echo "  cd compose && docker compose up -d"
echo "=============================================="
echo ""
