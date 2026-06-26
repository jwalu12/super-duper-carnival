#!/usr/bin/env sh
set -eu

docker compose ps
docker compose logs --tail 25 node
