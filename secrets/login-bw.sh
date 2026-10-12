#!/usr/bin/env bash
set -euo pipefail

# login-bw.sh — log the Bitwarden CLI in with a personal API key and store the
# unlock credentials in a 0600 file for later non-interactive use.

CREDS_FILE="$HOME/.config/bw/env"

if [[ -f "$CREDS_FILE" ]]; then
  echo "$CREDS_FILE already exists — remove it to re-login" >&2
  exit 1
fi

if [[ -z "${BW_CLIENTID:-}" ]]; then
  read -rp "Bitwarden client_id: " BW_CLIENTID
fi
if [[ -z "${BW_CLIENTSECRET:-}" ]]; then
  read -rsp "Bitwarden client_secret: " BW_CLIENTSECRET; echo
fi
if [[ -z "${BW_PASSWORD:-}" ]]; then
  read -rsp "Bitwarden master password: " BW_PASSWORD; echo
fi

BW_CLIENTID="$BW_CLIENTID" BW_CLIENTSECRET="$BW_CLIENTSECRET" bw login --apikey

umask 077
mkdir -p "$(dirname "$CREDS_FILE")"
cat > "$CREDS_FILE" <<EOF
BW_CLIENTID=$BW_CLIENTID
BW_CLIENTSECRET=$BW_CLIENTSECRET
BW_PASSWORD=$BW_PASSWORD
EOF
chmod 600 "$CREDS_FILE"

echo "stored credentials in $CREDS_FILE"
