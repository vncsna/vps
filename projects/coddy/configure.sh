#!/usr/bin/env bash
set -euo pipefail

# configure.sh — install the config and AGENTS.md, validate the config, and wire
# up git auth. Secrets must already be at ~/.config/coddy/.secrets (exported
# locally and copied over — see secrets/README.md).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECRETS_FILE="$HOME/.config/coddy/.secrets"
if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "missing $SECRETS_FILE — export locally and scp it over (see secrets/README.md)" >&2
  exit 1
fi

mkdir -p "$HOME/.coddy" "$HOME/coddy"
install -m 0600 "$SCRIPT_DIR/config.yaml" "$HOME/.coddy/config.yaml"
# Coddy always reads the agent home's AGENTS.md, whatever the workspace.
install -m 0644 "$SCRIPT_DIR/AGENTS.md" "$HOME/.coddy/AGENTS.md"

coddy -t

"$SCRIPT_DIR/setup-git.sh"
