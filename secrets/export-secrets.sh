#!/usr/bin/env bash
set -euo pipefail

# export-secrets.sh <project> [dest] — run on your LOCAL machine, not the server.
# Fetches the Bitwarden item "vps/<project>" and writes its custom fields as
# KEY=value lines to <dest> (default ./.env). Copy the result to the server.

PROJECT="${1:?usage: export-secrets.sh <project> [dest]}"
DEST="${2:-.env}"
ITEM="vps/$PROJECT"

bw get item "$ITEM" --session "$(bw unlock --raw)" \
  | jq -r '.fields[]? | select(.value != null and .value != "") | "\(.name)=\(.value)"' \
  > "$DEST"

echo "wrote $(wc -l < "$DEST") secrets to $DEST"
echo "copy to the server: scp $DEST deploy@<host>:~/.config/$PROJECT/.secrets"
