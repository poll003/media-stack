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
git clone https://github.com/jouw-gebruiker/media-stack.git
cd media-stack

# 2. Maak .env aan op basis van het voorbeeld
cp .env.example .env
nano .env  # Pas paden, PUID, PGID en TZ aan

# 3. Voer setup script uit (maakt alle mappen aan en controleert volumes)
bash scripts/setup.sh

# 4. Start de stack
cd compose
docker compose up -d
```

## PUID en PGID vinden

```bash
id
# uid=1000(gebruiker) gid=1000(gebruiker) ...
```

## Updates uitrollen

Updates van images worden automatisch uitgerold door Watchtower.

Voor configuratiewijzigingen (na een git pull):
```bash
cd compose
docker compose up -d
```

## Toegang

- **Lokaal netwerk:** `http://synology-ip:poort`
- **Onderweg:** Installeer Tailscale op je telefoon en gebruik `http://synology-tailscale-ip:poort`
- Geen publieke poorten nodig
