#!/usr/bin/env sh
set -eu

# =============================================================================
# Adshares Mainnet Docker Entrypoint
# =============================================================================
# This entrypoint configures the ADS node for mainnet operation.
# It validates credentials, creates options.cfg, and writes the secret key.
# =============================================================================

NODE_DIR="${ADS_NODE_DIR:-/home/ads/.adsd}"
NODE_ID="${NODE_ID:-0001}"
P2P_PORT="${P2P_PORT:-6510}"
OFFICE_PORT="${OFFICE_PORT:-${PORT:-6511}}"
INIT_NODE="${INIT_NODE:-false}"
PUBLIC_IP="${PUBLIC_IP:-0.0.0.0}"

try_chmod() {
    chmod "$@" 2>/dev/null || echo "Warning: could not chmod $*" >&2
}

# ============================================
# Validate node ID (1-8 hex characters)
# Updated for 8-character node IDs (e.g., 6A3EFA00)
# ============================================
case "${NODE_ID}" in
    *[!0-9A-Fa-f]*|"")
        echo "ERROR: NODE_ID must contain only hexadecimal characters (0-9, A-F)." >&2
        exit 1
        ;;
esac

if [ "${#NODE_ID}" -gt 8 ]; then
    echo "ERROR: NODE_ID must contain 1 to 8 hexadecimal characters (got ${#NODE_ID})." >&2
    exit 1
fi

if [ "${#NODE_ID}" -lt 1 ]; then
    echo "ERROR: NODE_ID must contain at least 1 hexadecimal character." >&2
    exit 1
fi

# ============================================
# Prepare data directory
# ============================================
mkdir -p "${NODE_DIR}/key"
try_chmod 0700 "${NODE_DIR}" "${NODE_DIR}/key"

# ============================================
# Create options.cfg (only if it doesn't exist)
# ============================================
if [ ! -f "${NODE_DIR}/options.cfg" ]; then
    echo "Creating node options.cfg..."
    cat > "${NODE_DIR}/options.cfg" <<EOF
svid=${NODE_ID}
offi=${OFFICE_PORT}
port=${P2P_PORT}
addr=${PUBLIC_IP}
EOF
    try_chmod 0600 "${NODE_DIR}/options.cfg"
fi

# ============================================
# Handle node secret from environment variable
# ============================================
if [ -n "${NODE_SECRET:-}" ]; then
    echo "Configuring node secret from NODE_SECRET environment variable..."
    secret="$(echo "${NODE_SECRET}" | tr -d '\r\n[:space:]')"
    case "${secret}" in
        *[!0-9A-Fa-f]*|"")
            echo "ERROR: The node secret must be a 64-character hexadecimal value." >&2
            exit 1
            ;;
    esac
    if [ "${#secret}" -ne 64 ]; then
        echo "ERROR: The node secret must be a 64-character hexadecimal value (got ${#secret} chars)." >&2
        exit 1
    fi
    printf '%s\n' "${secret}" > "${NODE_DIR}/key/key.txt"
    try_chmod 0600 "${NODE_DIR}/key/key.txt"
    echo "Node secret configured successfully."
# Handle node secret from file (for Render Secret Files or mounted volumes)
elif [ -n "${NODE_SECRET_FILE:-}" ] && [ -f "${NODE_SECRET_FILE}" ]; then
    echo "Configuring node secret from NODE_SECRET_FILE..."
    secret="$(tr -d '\r\n[:space:]' < "${NODE_SECRET_FILE}")"
    case "${secret}" in
        *[!0-9A-Fa-f]*|"")
            echo "ERROR: The node secret must be a 64-character hexadecimal value." >&2
            exit 1
            ;;
    esac
    if [ "${#secret}" -ne 64 ]; then
        echo "ERROR: The node secret must be a 64-character hexadecimal value (got ${#secret} chars)." >&2
        exit 1
    fi
    printf '%s\n' "${secret}" > "${NODE_DIR}/key/key.txt"
    try_chmod 0600 "${NODE_DIR}/key/key.txt"
    echo "Node secret configured successfully."
else
    echo "WARNING: No NODE_SECRET or NODE_SECRET_FILE provided. Node will use default key or fail to start." >&2
fi

# ============================================
# Mainnet: join existing network (do not init)
# ============================================
if [ "$#" -eq 0 ] || [ "$1" = "adsd" ]; then
    if [ "${INIT_NODE}" = "true" ] || [ "${INIT_NODE}" = "1" ]; then
        echo "WARNING: INIT_NODE=true — this will create a NEW blockchain (testnet mode)!" >&2
        set -- adsd --init=true -w "${NODE_DIR}"
    else
        echo "Starting ADS node in mainnet mode (joining existing network)..."
        set -- adsd -w "${NODE_DIR}"
    fi
fi

echo "Executing: $*"
exec "$@"
