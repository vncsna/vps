# Secrets

Secrets live in Bitwarden (cloud) and are exported on your local machine, then copied to the server. Nothing secret is committed to this repo, and the server never talks to Bitwarden.

## Vault layout

One Bitwarden item per project, named `vps/<project>` (e.g. `vps/agenvoy`). Each secret is a **custom field** whose name is the environment-variable name (e.g. `OPENROUTER_API_KEY`) and whose value is the secret. Use the "hidden" field type.

## Exporting (on your local machine)

Requires the Bitwarden CLI (`bw`) and `jq` installed locally, and logged in (`bw login`).

```bash
secrets/export-secrets.sh <project> [dest]
```

Fetches the `vps/<project>` item and writes its custom fields as `KEY=value` lines to `dest` (default `./.env`).

## Copying to the server

```bash
scp .env deploy@<host>:~/.config/<project>/.secrets
```

## Rotating a secret

Edit the Bitwarden item, re-export, and re-copy. Done.
