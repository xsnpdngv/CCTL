#!/usr/bin/env bash
#
# cctl container entrypoint.
#
# Wires up the default CodeChecker authentication configuration so the
# server starts with basic (dictionary) auth enabled out of the box and
# so client-side commands (analyze, store, ...) can authenticate even
# when the host has not yet provisioned ~/.codechecker/passwords.json.
#
#   Default credentials: admin / admin
#
# Customize by editing:
#   - server side (persistent, on host):
#       ~/.local/share/codechecker/workspace/server_config.json
#   - client side (persistent, on host):
#       ~/.codechecker/passwords.json

set -e

DEFAULT_SERVER_CONFIG="/etc/codechecker/server_config.json"
DEFAULT_PASSWORDS_FILE="/etc/codechecker/passwords.json"
WORKSPACE_SERVER_CONFIG="/workspace/server_config.json"
CLIENT_PASSWORDS_FILE="/root/.codechecker.passwords.json"

# Seed the bind-mounted server workspace with a default authenticated
# server_config.json on first run. We never overwrite an existing file
# so user customizations on the host are preserved.
if [ -d /workspace ] \
        && [ ! -e "$WORKSPACE_SERVER_CONFIG" ] \
        && [ -f "$DEFAULT_SERVER_CONFIG" ]; then
    # 644: the seeded contents are the public admin/admin default. Keep
    # them world-readable so the file remains usable even if the
    # container is later started under a different uid.
    install -m 644 "$DEFAULT_SERVER_CONFIG" "$WORKSPACE_SERVER_CONFIG"
    echo "[cctl-entrypoint] Seeded default server_config.json into" \
         "/workspace (basic auth enabled, admin/admin)."
fi

# If the client passwords file is missing or got materialized as an
# empty directory by Docker (this happens when the host bind-mount
# source does not exist), point CodeChecker at the baked-in defaults
# via the CC_PASS_FILE environment variable.
if [ ! -f "$CLIENT_PASSWORDS_FILE" ] && [ -f "$DEFAULT_PASSWORDS_FILE" ]; then
    export CC_PASS_FILE="$DEFAULT_PASSWORDS_FILE"
fi

# Docker auto-injects HTTP(S)_PROXY into every container from the host's
# ~/.docker/config.json. That makes the in-container CodeChecker client
# try to reach the sibling 'codechecker-server' container through the
# corporate HTTP proxy, which typically responds with 500 / "Tunnel
# connection failed". Ensure internal container hostnames bypass the
# proxy. Append rather than overwrite so any user-supplied NO_PROXY
# entries are preserved.
CCTL_NO_PROXY_HOSTS="codechecker-server,localhost,127.0.0.1,::1"
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}$CCTL_NO_PROXY_HOSTS"
export no_proxy="${no_proxy:+$no_proxy,}$CCTL_NO_PROXY_HOSTS"

exec "$@"
