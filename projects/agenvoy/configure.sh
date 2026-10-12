#!/usr/bin/env bash
set -euo pipefail

# configure.sh [openrouter-model] — sync secrets, register the OpenRouter model,
# and enable the Telegram bot. The daemon must be running for the model/channel
# calls to succeed.

MODEL="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 1. Sync secrets from Bitwarden into ~/.config/agenvoy/.secrets.
"$REPO_ROOT/secrets/sync-secrets.sh" agenvoy

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
