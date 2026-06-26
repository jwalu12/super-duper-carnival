#!/usr/bin/env sh
set -eu

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required." >&2
    exit 1
fi

if [ ! -f .env ]; then
    cp .env.example .env
fi

docker compose config >/dev/null
docker compose up -d --build
docker compose ps
