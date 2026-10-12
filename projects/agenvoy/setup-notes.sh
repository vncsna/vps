#!/usr/bin/env bash
set -euo pipefail

# setup-notes.sh <repo-url> — bootstrap the notes repo on the VPS.
# Creates ~/repos/, configures git identity, wires up GITHUB_TOKEN auth for
# pushes, clones the notes repo, and seeds profile.md.

REPO_URL="${1:?usage: setup-notes.sh <git-repo-url>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$HOME/repos"
NOTES_DIR="$WORKSPACE/notes"
SECRETS_FILE="$HOME/.config/agenvoy/.secrets"

# git identity
if ! git config --global user.name >/dev/null 2>&1; then
  read -rp "git user.name: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if ! git config --global user.email >/dev/null 2>&1; then
  read -rp "git user.email: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

# git auth for clone + pushes (GITHUB_TOKEN from .secrets) — must be set before
# cloning so private repos authenticate.
if [[ -f "$SECRETS_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
fi
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git config --global credential.helper store
  umask 077
  printf 'https://x-access-token:%s@github.com\n' "$GITHUB_TOKEN" > "$HOME/.git-credentials"
  chmod 600 "$HOME/.git-credentials"
  echo "configured git auth via GITHUB_TOKEN"
else
  echo "warning: GITHUB_TOKEN not found in $SECRETS_FILE — clone/push will prompt" >&2
fi

# workspace + clone
mkdir -p "$WORKSPACE"
if [[ ! -d "$NOTES_DIR/.git" ]]; then
  git clone "$REPO_URL" "$NOTES_DIR"
fi

# seed profile.md
if [[ ! -f "$NOTES_DIR/profile.md" ]]; then
  cp "$SCRIPT_DIR/profile.md.example" "$NOTES_DIR/profile.md"
  echo "seeded $NOTES_DIR/profile.md — edit it with your details"
fi
