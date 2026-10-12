#!/usr/bin/env bash
set -euo pipefail

# install-bw.sh — install the Bitwarden CLI native binary to /usr/local/bin.

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ASSET="bw-linux" ;;
  aarch64|arm64) ASSET="bw-linux-arm64" ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Latest CLI release tag (cli-vYYYY.M.D) from the clients repo.
TAG="$(curl -fsSL 'https://api.github.com/repos/bitwarden/clients/releases?per_page=100' \
  | jq -r '[.[].tag_name | select(startswith("cli-v"))][0]')"
VERSION="${TAG#cli-v}"

URL="https://github.com/bitwarden/clients/releases/download/${TAG}/${ASSET}-${VERSION}.zip"

curl -fsSL -o "$TMP/bw.zip" "$URL"
unzip -o "$TMP/bw.zip" -d "$TMP"
sudo install -m 0755 "$TMP/bw" /usr/local/bin/bw

bw --version
