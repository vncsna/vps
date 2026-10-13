#!/usr/bin/env bash
set -euo pipefail

# export-secrets.sh <project> [dest] — run on your LOCAL machine, not the server.
# Fetches the Bitwarden item "vps/<project>" and writes its custom fields as
# KEY=value lines to <dest> (default ./.secrets). Copy the result to the server.

PROJECT="${1:?usage: export-secrets.sh <project> [dest]}"
DEST="${2:-.secrets}"
ITEM="vps/$PROJECT"

# Write secrets with 0600 so they never land world-readable on disk (or on the
# server after scp, which preserves the mode).
umask 077

bw get item "$ITEM" --session "$(bw unlock --raw)" \
  | jq -r '.fields[]? | select(.value != null and .value != "") | "\(.name)=\(.value)"' \
  > "$DEST"

echo "wrote $(wc -l < "$DEST") secrets to $DEST"
echo "copy to the server:"
echo "  ssh <user>@<host> 'mkdir -p ~/.config/$PROJECT'"
echo "  scp $DEST <user>@<host>:~/.config/$PROJECT/.secrets"
