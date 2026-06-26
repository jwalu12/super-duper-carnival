# Adshares node — ready to use

This folder is the cleaned Docker/Render deployment package.

## Current working setup

- GitHub repo: <https://github.com/jwalu12/super-duper-carnival>
- Render Blueprint: <https://dashboard.render.com/blueprint/exs-d8utnrmgvqtc73bimbg0>
- Render private node service: <https://dashboard.render.com/pserv/srv-d8utoi6rnols73fmkob0>
- Render health cron: <https://dashboard.render.com/cron/crn-d8vb926rnols7385hq9g>

## Render service

The Render private service is `adshares-node-service`.

Internal Render addresses:

- P2P: `adshares-node-service:8091`
- Office/API health target: `adshares-node-service:9091`

The cron job `adshares-node-health-cron` runs every 10 minutes and checks:

```text
adshares-node-service:9091
```

To test it manually:

1. Open <https://dashboard.render.com/cron/crn-d8vb926rnols7385hq9g>
2. Click `Trigger Run`
3. Open the newest `Cron job run` log
4. Look for:

```text
ADS office endpoint healthy at adshares-node-service:9091
```

## Linux desktop service

The Linux desktop/WSL service is installed as:

```bash
adshares-node.service
```

Useful commands:

```bash
sudo systemctl status adshares-node.service
sudo systemctl restart adshares-node.service
sudo journalctl -u adshares-node.service -f
sudo systemctl status cron
```

Local listening ports verified:

- `28091`
- `29091`

## Updating Render

Make changes in this folder, commit/push to:

```text
https://github.com/jwalu12/super-duper-carnival
```

Render is connected to the GitHub repo and auto-deploys from `main`.

## Important files

- `render.yaml` — Render Blueprint for the private service and cron
- `Dockerfile` — Adshares node container
- `Dockerfile.cron` — lightweight cron health-check container
- `docker-entrypoint.sh` — node startup script
- `render-healthcheck.py` — cron health check
- `docker-compose.yml` — local Docker run option
- `.env.example` — environment template

## Note

`.env` is local-only and is not included in the clean zip package.
