# Adshares Mainnet Node Setup (VPS)

Quick-start guide for deploying your Adshares node on the **mainnet** using a VPS with a public IP address.

## ⚠️ Prerequisites

You **must** have the following before starting:

| Requirement | Description |
|-------------|-------------|
| **Node ID** | 4 hex characters (e.g., `A1B2`) registered in the Adshares network |
| **Secret Key** | 64 hex characters — your node's private key |
| **ADS Tokens** | Sufficient balance (~10,000+ ADS) if creating a new node via `create_node` |
| **VPS** | Cloud server with public static IP, Ubuntu 22.04 |

> **How to get Node ID & Secret?**
> - Contact the Adshares team via [GitHub](https://github.com/adshares/ads) or [Discord/Telegram](https://adshares.net)
> - Or create a node via `create_node` transaction using an existing funded account
> - Check the [Genesis Block](https://docs.adshares.net/ads/how-to-start-ads-node.html) for existing node assignments

## 🚀 Quick Start

### 1. Provision VPS & Open Firewall

```bash
# SSH into your VPS
ssh root@YOUR_VPS_IP

# Install UFW and open required ports
apt update && apt install -y ufw
ufw allow 6510/tcp   # P2P
ufw allow 6511/tcp   # Office
ufw allow 22/tcp     # SSH
ufw enable
```

### 2. Install Docker

```bash
apt install -y docker.io docker-compose
systemctl enable docker
systemctl start docker
```

### 3. Clone & Configure

```bash
# Clone your repo (or this mainnet-config branch)
git clone -b mainnet-config https://github.com/jwalu12/super-duper-carnival.git /opt/adshares-node
cd /opt/adshares-node

# Copy and edit environment file
cp .env.mainnet.example .env
nano .env
```

Fill in these values in `.env`:
```
NODE_ID=YOUR_4_HEX_NODE_ID
NODE_SECRET=YOUR_64_HEX_SECRET
PUBLIC_IP=YOUR_VPS_PUBLIC_IP
```

### 4. Start the Node

```bash
docker compose -f docker-compose.mainnet.yml up -d --build
```

### 5. Verify

```bash
# Check container status
docker compose -f docker-compose.mainnet.yml ps

# View logs
docker compose -f docker-compose.mainnet.yml logs -f adshares-node

# Check monitor
docker compose -f docker-compose.mainnet.yml exec monitor python3 /opt/adshares/monitor.py
```

## 🔧 Files in This Branch

| File | Purpose |
|------|---------|
| `.env.mainnet.example` | Environment variable template |
| `docker-compose.mainnet.yml` | Mainnet Docker Compose config |
| `docker-entrypoint-mainnet.sh` | Entrypoint adapted for mainnet |
| `README-MAINNET.md` | This file |

## 🌐 Mainnet vs Testnet Differences

| Setting | Testnet (Render) | Mainnet (VPS) |
|---------|-----------------|---------------|
| `INIT_NODE` | `true` | `false` |
| `NODE_ID` | `0001` | Your assigned ID |
| `NODE_SECRET` | Default | Your 64-hex secret |
| `P2P_PORT` | `8091` | `6510` |
| `OFFICE_PORT` | `9091` | `6511` |
| `PUBLIC_IP` | Internal | Your VPS public IP |
| Network | Isolated | Adshares mainnet |

## 📊 Monitoring

The monitor container prints node health every 60 seconds:
```
============================================================
ADSHARES NODE MONITOR
Time: 2025-06-26T17:00:00+00:00
Office endpoint: adshares-node:6511 (reachable)
Node volume: 45.2 MiB used / 10.0 GiB total
...
============================================================
```

## 🛡️ Security

- **Never commit `.env` or secrets to Git**
- Use a firewall (UFW) and only open ports 6510, 6511, 22
- Disable root SSH login: `PermitRootLogin no` in `/etc/ssh/sshd_config`
- Keep Docker and Ubuntu updated: `apt update && apt upgrade -y`

## 📚 Resources

- [Adshares Docs](https://docs.adshares.net/ads/)
- [How to Start ADS Node](https://docs.adshares.net/ads/how-to-start-ads-node.html)
- [ADS API](https://docs.adshares.net/ads/ads-api.html)
- [Full Migration Guide](https://github.com/jwalu12/super-duper-carnival/blob/mainnet-config/ADSHARES_MAINNET_MIGRATION_GUIDE.md)

## ⚠️ Disclaimer

Running a mainnet validator requires technical commitment, active monitoring, and sufficient ADS tokens for fees. This guide is based on ADS v1.1.5. Always verify current requirements with official Adshares documentation before committing funds.
