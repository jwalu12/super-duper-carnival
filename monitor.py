#!/usr/bin/env python3
"""Small container-friendly health monitor for an ADS node."""

from __future__ import annotations

import argparse
import shutil
import socket
import time
from datetime import datetime
from pathlib import Path


def endpoint_is_open(host: str, port: int, timeout: float = 3.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def format_bytes(value: int) -> str:
    size = float(value)
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if size < 1024 or unit == "TiB":
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TiB"


def cgroup_memory() -> str:
    current_path = Path("/sys/fs/cgroup/memory.current")
    maximum_path = Path("/sys/fs/cgroup/memory.max")
    try:
        current = int(current_path.read_text(encoding="utf-8").strip())
        maximum_raw = maximum_path.read_text(encoding="utf-8").strip()
        maximum = "unlimited" if maximum_raw == "max" else format_bytes(int(maximum_raw))
        return f"{format_bytes(current)} used / {maximum}"
    except (OSError, ValueError):
        return "unavailable"


def recent_logs(node_dir: Path, count: int = 5) -> list[str]:
    log_file = node_dir / "log.txt"
    try:
        return log_file.read_text(encoding="utf-8", errors="replace").splitlines()[-count:]
    except OSError:
        return []


def display(host: str, port: int, node_dir: Path) -> None:
    usage = shutil.disk_usage(node_dir)
    healthy = endpoint_is_open(host, port)

    print("=" * 60, flush=True)
    print("ADSHARES NODE MONITOR", flush=True)
    print(f"Time: {datetime.now().astimezone().isoformat(timespec='seconds')}", flush=True)
    print(f"Office endpoint: {host}:{port} ({'reachable' if healthy else 'unreachable'})", flush=True)
    print(
        f"Node volume: {format_bytes(usage.used)} used / "
        f"{format_bytes(usage.total)} total",
        flush=True,
    )
    print(f"Container memory: {cgroup_memory()}", flush=True)

    logs = recent_logs(node_dir)
    if logs:
        print("Recent node log lines:", flush=True)
        for line in logs:
            print(f"  {line}", flush=True)
    else:
        print("Recent node log lines: none found", flush=True)
    print("=" * 60, flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=9091)
    parser.add_argument("--node-dir", type=Path, default=Path("/home/ads/.adsd"))
    parser.add_argument("--watch", type=int, metavar="SECONDS")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.watch is not None and args.watch < 1:
        raise SystemExit("--watch must be at least 1 second")

    while True:
        display(args.host, args.port, args.node_dir)
        if args.watch is None:
            return
        time.sleep(args.watch)


if __name__ == "__main__":
    main()
