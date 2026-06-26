# Setup guide

## Local test deployment

1. Install and start Docker Desktop.
2. Copy `.env.example` to `.env`.
3. Keep `NODE_ID=0001` and `INIT_NODE=true` for the first local test.
4. Run `docker compose up -d --build`.
5. Wait for `docker compose ps` to report a healthy node.
6. Review output with `docker compose logs -f node`.

The first build compiles the official ADS source and may take several minutes.
The image uses a pinned source tag so later rebuilds are repeatable.

## Persistence

The node writes to the `node-data` volume and wallet/user files belong in the
`user-data` volume. `docker compose down` preserves both. Back up keys before
any migration, reset, or volume deletion.

## Security

- Ports bind only to localhost by default.
- The node runs as a non-root user.
- Linux capabilities are dropped.
- The container root filesystem is read-only.
- Secrets are not accepted through the supplied `.env.example`.
- `.env`, logs, bytecode, and backups are ignored by Git.

## Production/mainnet warning

The local-testnet initialization flow is not a substitute for Adshares
mainnet enrollment. A production node needs real node credentials and network
configuration. Use the official documentation and verify current requirements
before exposing ports or funding an account.

Official documentation:

- https://docs.adshares.net/ads/installation.html
- https://docs.adshares.net/ads/how-to-start-ads-node.html
- https://docs.adshares.net/ads/setting-up-a-local-test-net.html
