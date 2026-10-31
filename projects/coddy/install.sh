#!/usr/bin/env bash
set -euo pipefail

# install.sh — install a pinned coddy release binary.

VERSION="1.3.70"

# Pin the release asset: SHA256SUMS is fetched from the same release, so it
# only proves the download arrived intact. Bump VERSION and the hash together.
case "$(uname -m)" in
  x86_64|amd64) ARCH="amd64"; ASSET_SHA256="63ab3f2d5141072cb41b9e3d6f4ba72fd1d8f683a1aa0731eb2c3b2211d2d68a" ;;
  aarch64|arm64) ARCH="arm64"; ASSET_SHA256="708ead489ba3d28e69d2ca535620bbe8d60f3c65503094591ae05a56deab2d09" ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

BASE="https://github.com/coddy-project/coddy-agent/releases/download/${VERSION}"
ASSET="coddy_${VERSION}_linux_${ARCH}.tar.gz"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$BASE/$ASSET" -o "$TMP/$ASSET"
echo "$ASSET_SHA256  $TMP/$ASSET" | sha256sum -c -

tar -xzf "$TMP/$ASSET" -C "$TMP" coddy
sudo install -m 0755 "$TMP/coddy" /usr/local/bin/coddy

coddy --version
