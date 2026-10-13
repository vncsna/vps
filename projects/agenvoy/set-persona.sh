#!/usr/bin/env bash
set -euo pipefail

# set-persona.sh [session-id] — apply persona.md to a session via the REST API.
# With no session id, lists sessions so you can pick one.

SESSION_ID="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONA_FILE="$SCRIPT_DIR/persona.md"

if [[ -z "$SESSION_ID" ]]; then
  echo "sessions:" >&2
  curl -fsS http://127.0.0.1:17989/v1/sessions | jq -r '.sessions[] | "\(.id)  \(.name)"'
  echo >&2
  echo "usage: set-persona.sh <session-id>" >&2
  exit 1
fi

jq -n --rawfile role "$PERSONA_FILE" '{role: $role}' \
  | curl -fsS -X POST "http://127.0.0.1:17989/v1/session/$SESSION_ID" \
      -H 'Content-Type: application/json' \
      -d @-
echo
