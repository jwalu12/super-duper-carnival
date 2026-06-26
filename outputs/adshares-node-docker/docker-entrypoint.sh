#!/usr/bin/env sh
set -eu

NODE_DIR="${ADS_NODE_DIR:-/home/ads/.adsd}"
NODE_ID="${NODE_ID:-0001}"
P2P_PORT="${P2P_PORT:-8091}"
OFFICE_PORT="${OFFICE_PORT:-9091}"
INIT_NODE="${INIT_NODE:-true}"

case "${NODE_ID}" in
    *[!0-9A-Fa-f]*|"")
        echo "NODE_ID must contain 1 to 4 hexadecimal characters." >&2
        exit 1
        ;;
esac

if [ "${#NODE_ID}" -gt 4 ]; then
    echo "NODE_ID must contain 1 to 4 hexadecimal characters." >&2
    exit 1
fi

mkdir -p "${NODE_DIR}/key"
chmod 0700 "${NODE_DIR}" "${NODE_DIR}/key"

if [ ! -f "${NODE_DIR}/options.cfg" ]; then
    cat > "${NODE_DIR}/options.cfg" <<EOF
svid=${NODE_ID}
offi=${OFFICE_PORT}
port=${P2P_PORT}
addr=0.0.0.0
EOF
    chmod 0600 "${NODE_DIR}/options.cfg"
fi

if [ -n "${NODE_SECRET_FILE:-}" ] && [ -f "${NODE_SECRET_FILE}" ]; then
    secret="$(tr -d '\r\n[:space:]' < "${NODE_SECRET_FILE}")"
    case "${secret}" in
        *[!0-9A-Fa-f]*|"")
            echo "The node secret must be a 64-character hexadecimal value." >&2
            exit 1
            ;;
    esac
    if [ "${#secret}" -ne 64 ]; then
        echo "The node secret must be a 64-character hexadecimal value." >&2
        exit 1
    fi
    printf '%s\n' "${secret}" > "${NODE_DIR}/key/key.txt"
    chmod 0600 "${NODE_DIR}/key/key.txt"
fi

if [ "$#" -eq 0 ] || [ "$1" = "adsd" ]; then
    if [ "${INIT_NODE}" = "true" ] || [ "${INIT_NODE}" = "1" ]; then
        set -- adsd --init=true -w "${NODE_DIR}"
    else
        set -- adsd -w "${NODE_DIR}"
    fi
fi

exec "$@"
