#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update >/dev/null
apt-get install -y gh >/dev/null

: > /tmp/gh-auth.log
: > /tmp/gh-auth.status

nohup bash -c '
  script -q -f -c "gh auth login \
    --hostname github.com \
    --web \
    --scopes repo" /tmp/gh-auth.log
  printf "%s\n" "$?" > /tmp/gh-auth.status
' >/dev/null 2>&1 &

echo /tmp/gh-auth.log
echo /tmp/gh-auth.status
