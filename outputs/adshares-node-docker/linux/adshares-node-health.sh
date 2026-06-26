#!/usr/bin/env bash
set -euo pipefail

service_name="adshares-node.service"
office_host="127.0.0.1"
office_port="29091"

if ! systemctl is-active --quiet "${service_name}"; then
    logger -t adshares-health "${service_name} was inactive; restarting"
    systemctl restart "${service_name}"
    sleep 3
fi

if timeout 3 bash -c "</dev/tcp/${office_host}/${office_port}" 2>/dev/null; then
    logger -t adshares-health "healthy: ${office_host}:${office_port}"
else
    logger -t adshares-health "office endpoint unavailable; restarting ${service_name}"
    systemctl restart "${service_name}"
fi
