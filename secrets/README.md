# Secrets

Secrets live in Bitwarden (cloud) and are fetched onto the server with the Bitwarden CLI. Nothing secret is committed to this repo.

## Vault layout

One Bitwarden item per project, named `vps/<project>` (e.g. `vps/agenvoy`). Each secret is a **custom field** whose name is the environment-variable name (e.g. `OPENROUTER_API_KEY`) and whose value is the secret. Use the "hidden" field type.

## Setup (once per server)

1. `install-bw.sh` — installs the `bw` CLI.
2. `login-bw.sh` — logs in with a [personal API key](https://bitwarden.com/help/personal-api-key/) and stores the unlock credentials in `~/.config/bw/env` (0600).

The `~/.config/bw/env` file is the one unavoidable local secret: it holds `BW_CLIENTID`, `BW_CLIENTSECRET`, and `BW_PASSWORD` (the master password is required to unlock the vault, even with API-key login). Everything else stays in Bitwarden.

## Syncing

```bash
secrets/sync-secrets.sh <project> [dest]
```

Fetches the `vps/<project>` item and writes its custom fields as `KEY=value` lines to `dest` (default `~/.config/<project>/.secrets`). Re-run whenever you rotate a secret.

## Rotating a secret

Edit the Bitwarden item, then re-run `sync-secrets.sh <project>`. Done.
