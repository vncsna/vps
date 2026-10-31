#!/usr/bin/env bash
set -euo pipefail

# setup-git.sh — wire GITHUB_TOKEN into git's credential helper and create the
# workspace repos directory. Idempotent; re-run after rotating the token.

SECRETS_FILE="$HOME/.config/coddy/.secrets"
REPOS_DIR="$HOME/coddy/repos"

if [[ -f "$SECRETS_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    printf -v "$key" '%s' "$value"
  done < "$SECRETS_FILE"
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "warning: GITHUB_TOKEN not found in $SECRETS_FILE — clone/push will prompt" >&2
else
  # Prefer the Secret Service keyring (encrypted at rest) over a plaintext
  # credential file when git ships the helper. Stock Debian 12 does not, so
  # this falls back to a 0600 plaintext file.
  use_keyring=0
  if [[ -x "$(git --exec-path)/git-credential-libsecret" ]]; then
    git config --global credential.helper libsecret
    if printf 'protocol=https\nhost=github.com\nusername=x-access-token\npassword=%s\n' \
        "$GITHUB_TOKEN" | git credential approve 2>/dev/null; then
      use_keyring=1
    fi
  fi
  if [[ "$use_keyring" -eq 0 ]]; then
    git config --global credential.helper store
    umask 077
    printf 'https://x-access-token:%s@github.com\n' "$GITHUB_TOKEN" > "$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
  fi
  echo "configured git auth via GITHUB_TOKEN"
fi

mkdir -p "$REPOS_DIR"
