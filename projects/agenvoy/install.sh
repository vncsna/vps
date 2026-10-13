#!/usr/bin/env bash
set -euo pipefail

# install.sh — install agenvoy and its dependencies.

curl -fsSL https://agenvoy.com/scripts/install.sh -o /tmp/agenvoy-install.sh
bash /tmp/agenvoy-install.sh

command -v agen
