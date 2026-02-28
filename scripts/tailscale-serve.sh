#!/usr/bin/env bash
# ============================================================
# Tailscale Serve - Setup script
# Stelt Jellyfin beschikbaar via Tailscale voor toegang onderweg.
# Overige services zijn alleen bereikbaar via het lokale netwerk.
#
# Gebruik: sudo bash scripts/tailscale-serve.sh
#
# Na uitvoeren bereikbaar via:
#   https://synology-naam.tailnet-naam.ts.net/jellyfin
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

configure_serve "jellyfin"   "${PORT_JELLYFIN}"

echo ""
echo "--- Huidige Tailscale Serve status ---"
tailscale serve status

echo ""
echo "=============================================="
log_ok "Tailscale Serve geconfigureerd!"
echo ""
echo "Jellyfin bereikbaar via Tailscale:"
TAILSCALE_NAME=$(tailscale status --json | grep -o '"DNSName":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\.$//')
if [ -n "$TAILSCALE_NAME" ]; then
  echo "  https://$TAILSCALE_NAME/jellyfin"
else
  echo "  https://[synology-tailscale-naam]/jellyfin"
fi
echo ""
echo "Overige services alleen via LAN (http://[synology-naam]:poort)"
echo "=============================================="
echo ""
