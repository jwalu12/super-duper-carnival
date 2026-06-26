# Adshares Node Docker Setup

This cleaned package builds the official `adshares/ads` source and runs one
ADS node in Docker. It defaults to a local test network using node ID `0001`
and localhost-only ports.

It is not automatically a mainnet validator. Mainnet operation requires a
valid assigned node ID, a 64-character node secret, correct network
configuration, synchronized host time, public networking, and operational
coordination described by Adshares.

## Quick start

PowerShell:

```powershell
Copy-Item .env.example .env
docker compose config
docker compose up -d --build
docker compose ps
docker compose logs -f node
```

Stop the stack without deleting blockchain data:

```powershell
docker compose down
```

Start the optional monitor:

```powershell
docker compose --profile monitoring up -d monitor
docker compose logs -f monitor
```

## Defaults

- Official source ref: `v1.1.5`
- P2P endpoint: `127.0.0.1:8091`
- Office endpoint: `127.0.0.1:9091`
- Persistent volumes: `node-data` and `user-data`
- Container process: unprivileged user with dropped Linux capabilities

Edit `.env` before deployment. Do not commit `.env`, keys, wallet settings, or
backups.

On the workstation where this package was prepared, another container already
owned ports 8091 and 9091. The included active `.env` therefore maps this
deployment to `127.0.0.1:18091` and `127.0.0.1:19091`. The `.env.example`
retains the standard local defaults for a fresh machine.

## Useful commands

```powershell
docker compose ps
docker compose logs --tail 100 node
docker compose restart node
docker compose exec node adsd -v
docker compose exec node ads -v
docker compose exec node python3 /opt/adshares/monitor.py
docker compose run --rm node python3 /opt/adshares/rewards_calculator.py
```

Do not run `docker compose down -v` unless you intentionally want to delete
the node and user volumes.

Official references:

- https://github.com/adshares/ads
- https://docs.adshares.net/ads/installation.html
- https://docs.adshares.net/ads/setting-up-a-local-test-net.html
- https://docs.adshares.net/ads/how-to-start-ads-node.html

## Linux Desktop

The `linux/` directory contains a systemd service and a five-minute cron
health check. The desktop deployment uses native ADS binaries and separate
ports so it does not collide with Docker Desktop:

- P2P: `28091`
- Office: `29091`

## Render

`render.yaml` defines:

- A continuously running Docker private service with a 10 GB persistent disk.
- A cron probe every ten minutes.

Render cron jobs cannot attach persistent disks and are stopped after twelve
hours, so the node itself must run as a continuous service. Render private
services accept traffic only from the Render private network; this
configuration is therefore for an isolated test node, not a public validator.
