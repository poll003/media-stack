#!/usr/bin/env bash
# ============================================================
# Tailscale Serve - Setup script
# Maakt alle media stack services bereikbaar via Tailscale
# zonder open poorten
#
# Gebruik: sudo bash scripts/tailscale-serve.sh
#
# Na uitvoeren bereikbaar via:
#   https://synology-naam.tailnet-naam.ts.net/sabnzbd
#   https://synology-naam.tailnet-naam.ts.net/sonarr
#   etc.
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok()   { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Controleer of tailscale beschikbaar is ---
if ! command -v tailscale &>/dev/null; then
  log_err "Tailscale niet gevonden. Zorg dat Tailscale is geïnstalleerd op de Synology."
  exit 1
fi

# --- Laad poorten uit .env ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [ ! -f "$ENV_FILE" ]; then
  log_err ".env bestand niet gevonden op: $ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

echo ""
echo "=============================================="
echo "  Tailscale Serve - Media Stack"
echo "=============================================="
echo ""

# --- Configureer Tailscale Serve per service ---
configure_serve() {
  local name="$1"
  local port="$2"

  tailscale serve --set-path "/$name" "http://localhost:$port" 2>/dev/null \
    && log_ok "Serve geconfigureerd: /$name → localhost:$port" \
    || log_warn "Kon serve niet instellen voor $name"
}

configure_serve "sabnzbd"    "${PORT_SABNZBD}"
configure_serve "prowlarr"   "${PORT_PROWLARR}"
configure_serve "sonarr"     "${PORT_SONARR}"
configure_serve "radarr"     "${PORT_RADARR}"
configure_serve "lidarr"     "${PORT_LIDARR}"
configure_serve "bazarr"     "${PORT_BAZARR}"
configure_serve "jellyfin"   "${PORT_JELLYFIN}"
configure_serve "jellyseerr" "${PORT_JELLYSEERR}"

echo ""
echo "--- Huidige Tailscale Serve status ---"
tailscale serve status

echo ""
echo "=============================================="
log_ok "Tailscale Serve geconfigureerd!"
echo ""
echo "Services bereikbaar via:"
TAILSCALE_NAME=$(tailscale status --json | grep -o '"DNSName":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\.$//')
if [ -n "$TAILSCALE_NAME" ]; then
  for service in sabnzbd prowlarr sonarr radarr lidarr bazarr jellyfin jellyseerr; do
    echo "  https://$TAILSCALE_NAME/$service"
  done
else
  echo "  https://[synology-tailscale-naam]/[service]"
fi
echo "=============================================="
echo ""
