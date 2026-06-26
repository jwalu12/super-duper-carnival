#!/usr/bin/env bash
set -euo pipefail

pkill -f 'gh auth login' 2>/dev/null || true
: > /tmp/gh-pipe-live.log
: > /tmp/gh-pipe-live.status

nohup bash -c '
  bash /mnt/c/Users/jonaw/Documents/Codex/2026-06-25/n/work/gh-login-pipe.sh \
    > /tmp/gh-pipe-live.log 2>&1
  printf "%s\n" "$?" > /tmp/gh-pipe-live.status
' >/dev/null 2>&1 &

sleep 3
cat /tmp/gh-pipe-live.log
printf '\nSTATUS:'
cat /tmp/gh-pipe-live.status
ps aux | grep '[g]h auth login' || true
