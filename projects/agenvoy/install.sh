#!/usr/bin/env bash
set -euo pipefail

# install.sh — install agenvoy and its dependencies.

curl -fsSL https://agenvoy.com/scripts/install.sh | bash

command -v agen
