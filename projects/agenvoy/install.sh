#!/usr/bin/env bash
set -euo pipefail

# install.sh — install agenvoy and its dependencies.

# Fetch the upstream installer and verify its checksum before running it. The
# installer itself verifies the binary's checksum; pinning the bootstrap script
# closes the remaining supply-chain gap. Bump the hash when the script changes.
INSTALLER_SHA256="08104aadd31d71f08630900d0914844f7de9b2a56a83ee20b4a249e657224b8b"
curl -fsSL https://agenvoy.com/scripts/install.sh -o /tmp/agenvoy-install.sh
echo "$INSTALLER_SHA256  /tmp/agenvoy-install.sh" | sha256sum -c -

bash /tmp/agenvoy-install.sh

command -v agen
