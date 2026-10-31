#!/usr/bin/env bash
set -euo pipefail

# install.sh — install a pinned coddy release binary.

VERSION="1.3.70"

case "$(uname -m)" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

BASE="https://github.com/coddy-project/coddy-agent/releases/download/${VERSION}"
ASSET="coddy_${VERSION}_linux_${ARCH}.tar.gz"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$BASE/$ASSET" -o "$TMP/$ASSET"
curl -fsSL "$BASE/SHA256SUMS" -o "$TMP/SHA256SUMS"
(cd "$TMP" && grep " ${ASSET}\$" SHA256SUMS | sha256sum -c -)

tar -xzf "$TMP/$ASSET" -C "$TMP" coddy
sudo install -m 0755 "$TMP/coddy" /usr/local/bin/coddy

coddy --version
