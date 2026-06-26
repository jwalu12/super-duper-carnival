#!/usr/bin/env bash
set -u
printf '\n' | gh auth login --hostname github.com --web --scopes repo
