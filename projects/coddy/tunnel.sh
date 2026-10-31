#!/usr/bin/env bash
set -euo pipefail

# tunnel.sh <user@host> — forward the coddy web UI/API to localhost.

HOST="${1:?usage: tunnel.sh <user@host>}"

exec ssh -N -L 12345:127.0.0.1:12345 "$HOST"
