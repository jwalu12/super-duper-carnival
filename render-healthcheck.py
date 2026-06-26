#!/usr/bin/env python3
"""One-shot Render cron probe for the continuously running ADS worker."""

from __future__ import annotations

import os
import socket
import sys
from datetime import datetime, timezone


def main() -> int:
    host = os.environ.get("ADS_NODE_HOST", "adshares-node-worker")
    port = int(os.environ.get("ADS_NODE_PORT", "9091"))
    timeout = float(os.environ.get("ADS_HEALTH_TIMEOUT", "10"))
    timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds")

    try:
        with socket.create_connection((host, port), timeout=timeout):
            print(f"{timestamp} ADS office endpoint healthy at {host}:{port}")
            return 0
    except OSError as error:
        print(
            f"{timestamp} ADS office endpoint unavailable at {host}:{port}: {error}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
