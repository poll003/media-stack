# Media Stack

Volledige media stack gebaseerd op Docker Compose.  
Automatische image updates via Watchtower, CI/CD via GitHub Actions.

## Stack

| Service | Functie | Poort |
|---|---|---|
| SABnzbd | Usenet download client | 8080 |
| Prowlarr | Indexer manager | 9696 |
| Sonarr | Series beheer | 8989 |
| Radarr | Film beheer | 7878 |
| Lidarr | Muziek beheer | 8686 |
| Bazarr | Ondertitels | 6767 |
| Jellyfin | Media server | 8096 |
| Jellyseerr | Request portal | 5055 |
| Recyclarr | Kwaliteitsprofielen sync | - |
| Watchtower | Automatische updates | - |

## Eerste installatie

```bash
# 1. Clone de repo op je Synology (via Tailscale SSH)
git clone https://github.com/poll003/media-stack.git /volume1/docker/media-stack
cd /volume1/docker/media-stack

# 2. Maak .env aan op basis van het voorbeeld
cp .env.example .env
nano .env  # Pas PUID, PGID en TZ aan indien nodig

# 3. Voer setup script uit (maakt alle mappen aan en controleert volumes)
bash scripts/setup.sh

# 4. Start de stack
docker compose up -d
```

## PUID en PGID vinden

```bash
id
# uid=1029(gebruiker) gid=1029(gebruiker) ...
```

## Updates uitrollen

Updates van images worden automatisch uitgerold door Watchtower.

Voor configuratiewijzigingen (na een git pull):
```bash
cd /volume1/docker/media-stack
git pull
docker compose up -d
```

## Volume strategie

| Locatie | Inhoud |
|---|---|
| `/volume1/docker` | SABnzbd, Jellyfin, Jellyseerr, Recyclarr config |
| `/volume2/Databases_SSD` | ARR app databases (Sonarr, Radarr, Prowlarr, Lidarr, Bazarr, Jellyfin cache) |
| `/volume1/Media` | Alle media bestanden |

## Toegang via Tailscale Serve

Eenmalig instellen zodat alle services bereikbaar zijn via Tailscale zonder open poorten:

```bash
sudo bash scripts/tailscale-serve.sh
```

Daarna bereikbaar via:

| Service | URL |
|---|---|
| SABnzbd | `https://synology.tailnet.ts.net/sabnzbd` |
| Prowlarr | `https://synology.tailnet.ts.net/prowlarr` |
| Sonarr | `https://synology.tailnet.ts.net/sonarr` |
| Radarr | `https://synology.tailnet.ts.net/radarr` |
| Lidarr | `https://synology.tailnet.ts.net/lidarr` |
| Bazarr | `https://synology.tailnet.ts.net/bazarr` |
| Jellyfin | `https://synology.tailnet.ts.net/jellyfin` |
| Jellyseerr | `https://synology.tailnet.ts.net/jellyseerr` |

- **Lokaal thuis (TV):** `http://192.168.1.250:poort`
- **Onderweg:** verbind via Tailscale en gebruik bovenstaande URLs

## Permissions handmatig herstellen

Als containers niet opstarten vanwege `Permission denied` fouten voer dan het volgende uit. Let op: Synology maakt `config` submappen soms aan als groep `docker` in plaats van jouw gebruiker, vandaar dat we expliciet de submappen meenemen:

```bash
sudo chown -R 1029:1029 \
  /volume1/docker/sabnzbd \
  /volume1/docker/sabnzbd/config \
  /volume1/docker/prowlarr \
  /volume1/docker/prowlarr/config \
  /volume1/docker/sonarr \
  /volume1/docker/sonarr/config \
  /volume1/docker/radarr \
  /volume1/docker/radarr/config \
  /volume1/docker/lidarr \
  /volume1/docker/lidarr/config \
  /volume1/docker/bazarr \
  /volume1/docker/bazarr/config \
  /volume1/docker/jellyfin \
  /volume1/docker/jellyfin/config \
  /volume1/docker/jellyseerr \
  /volume1/docker/jellyseerr/config \
  /volume1/docker/recyclarr \
  /volume1/docker/recyclarr/config \
  /volume1/Media \
  /volume2/Databases_SSD

docker compose restart
```

Vervang `1029` door jouw eigen PUID/PGID (controleer met `id`).
