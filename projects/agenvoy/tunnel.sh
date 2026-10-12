#!/usr/bin/env bash
set -euo pipefail

# tunnel.sh <user@host> — forward the agenvoy dashboard/API to localhost.

HOST="${1:?usage: tunnel.sh <user@host>}"

exec ssh -N -L 17989:127.0.0.1:17989 "$HOST"
