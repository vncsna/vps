#!/usr/bin/env bash
set -euo pipefail

# sync-secrets.sh <project> [dest]
# Fetch the Bitwarden item "vps/<project>" and write its custom fields as
# KEY=value lines to <dest> (default ~/.config/<project>/.secrets).

PROJECT="${1:?usage: sync-secrets.sh <project> [dest]}"
DEST="${2:-$HOME/.config/$PROJECT/.secrets}"
ITEM="vps/$PROJECT"

CREDS_FILE="$HOME/.config/bw/env"
if [[ ! -f "$CREDS_FILE" ]]; then
  echo "missing $CREDS_FILE — run secrets/login-bw.sh first" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CREDS_FILE"

# Log in only if needed, then unlock to get a session key.
if [[ "$(bw status 2>/dev/null | jq -r '.status')" == "unauthenticated" ]]; then
  BW_CLIENTID="$BW_CLIENTID" BW_CLIENTSECRET="$BW_CLIENTSECRET" bw login --apikey >/dev/null
fi
SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)"
trap 'bw lock >/dev/null 2>&1 || true' EXIT

bw sync --session "$SESSION" >/dev/null

ITEM_JSON="$(bw get item "$ITEM" --session "$SESSION")"

mkdir -p "$(dirname "$DEST")"
umask 077
echo "$ITEM_JSON" | jq -r '.fields[]? | select(.value != null and .value != "") | "\(.name)=\(.value)"' > "$DEST"
chmod 600 "$DEST"

if [[ ! -s "$DEST" ]]; then
  echo "warning: no fields found on item '$ITEM'" >&2
fi

echo "wrote $(wc -l < "$DEST") secrets to $DEST"
