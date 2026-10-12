#!/usr/bin/env bash
set -euo pipefail

# configure.sh [openrouter-model] [notes-repo-url] — sync secrets, register the
# OpenRouter model, enable the Telegram bot, and (optionally) bootstrap the
# notes repo. The daemon must be running for the model/channel calls to succeed.

MODEL="${1:-}"
NOTES_REPO="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Secrets must already be present (exported locally and copied over — see secrets/README.md).
SECRETS_FILE="$HOME/.config/agenvoy/.secrets"
if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "missing $SECRETS_FILE — export locally and scp it over (see secrets/README.md)" >&2
  exit 1
fi

# 2. Register the OpenRouter model.
if [[ -n "$MODEL" ]]; then
  curl -fsS -X POST http://127.0.0.1:17989/v1/models \
    -H 'Content-Type: application/json' \
    -d "{\"name\":\"openrouter@$MODEL\"}"
  echo
fi

# 3. Enable the Telegram bot (token already in .secrets).
curl -fsS -X POST http://127.0.0.1:17989/v1/channel/telegram \
  -H 'Content-Type: application/json' \
  -d '{"action":"enable"}'
echo

# 4. Bootstrap the notes repo (optional).
if [[ -n "$NOTES_REPO" ]]; then
  "$SCRIPT_DIR/setup-notes.sh" "$NOTES_REPO"
fi
