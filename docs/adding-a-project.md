# Adding a project

Each project is a self-contained folder under `projects/` that reuses the shared bootstrap and secrets layers.

## Steps

1. Copy the template:

   ```bash
   cp -r projects/_template projects/<name>
   ```

2. Fill in `secrets.env.example` with the keys the project needs, and create a matching Bitwarden item named `vps/<name>` with one custom field per key.

3. Write `install.sh` (install the software) and `configure.sh` (sync secrets and configure it).

4. Add systemd units under `systemd/`.

5. On the server:

   ```bash
   secrets/sync-secrets.sh <name>
   projects/<name>/install.sh
   projects/<name>/configure.sh
   sudo cp projects/<name>/systemd/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now <name>
   ```

6. Document the project in its `README.md`.

## Conventions

- Secrets are never committed — only `*.env.example` manifests are tracked.
- `sync-secrets.sh <name>` writes to `~/.config/<name>/.secrets` by default; pass a second argument to override the destination.
- Keep `install.sh` and `configure.sh` idempotent so they can be re-run safely.
