# Adding a project

Each project is a self-contained folder under `projects/` that reuses the shared setup and secrets layers.

## Steps

1. Copy the template:

   ```bash
   cp -r projects/_template projects/<name>
   ```

2. Fill in `secrets.env.example` with the keys the project needs, and create a matching Bitwarden item named `vps/<name>` with one custom field per key.

3. Write `install.sh` (install the software) and `configure.sh` (configure it; secrets are already copied over).

4. Add systemd units under `systemd/`.

5. Export secrets locally and copy them over, then on the server:

   ```bash
   secrets/export-secrets.sh <name>          # on your local machine
   scp .secrets deploy@<host>:~/.config/<name>/.secrets
   projects/<name>/install.sh
   projects/<name>/configure.sh
   sudo cp projects/<name>/systemd/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now <name>
   ```

6. Document the project in its `README.md`.

## Conventions

- Secrets are never committed — only `*.env.example` manifests are tracked.
- `export-secrets.sh <name>` writes to `./.secrets` by default; pass a second argument to override the destination. Copy it to `~/.config/<name>/.secrets` on the server.
- Keep `install.sh` and `configure.sh` idempotent so they can be re-run safely.
