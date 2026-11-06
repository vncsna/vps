# Adding a project

Each project is a self-contained folder under `projects/` that reuses the shared setup scripts.

## Steps

1. Create the project folder and files, filling them in as you go:

   ```bash
   mkdir -p projects/<name>/systemd
   ```

   `install.sh` — installs the software:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   # install.sh — install <name> and its dependencies.
   ```

   `configure.sh` — configures it (secrets are already copied over):

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   # configure.sh — configure <name> (secrets already copied over).
   ```

   `secrets.env.example` — the keys the project needs:

   ```bash
   # Keys this project needs, fetched from the Bitwarden item "vps/<name>".
   # Add one KEY= line per secret; export-secrets.sh fills the values.
   # EXAMPLE_KEY=
   ```

   `systemd/<name>.service`:

   ```ini
   [Unit]
   Description=<name> daemon
   After=network-online.target
   Wants=network-online.target

   [Service]
   Type=simple
   # Run as the user whose ~/.config/<name> holds the config and .secrets.
   User=<user>
   ExecStart=/usr/local/bin/<name> --daemon
   Restart=on-failure
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

2. Create a matching Bitwarden item named `vps/<name>` with one custom field per key in `secrets.env.example`.

3. Export secrets locally and copy them over, then on the server:

   ```bash
   scripts/export-secrets.sh <name>            # on your local machine
   ssh <user>@<host> 'mkdir -p ~/.config/<name>'
   scp .secrets <user>@<host>:~/.config/<name>/.secrets
   projects/<name>/install.sh
   projects/<name>/configure.sh
   sudo cp projects/<name>/systemd/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now <name>
   ```

4. Document the project in its `README.md`:

   ````markdown
   # <name>

   One-line description of what this project does.

   ## Prerequisites

   - [Scripts](../scripts/README.md) done.
   - [Secrets exported and copied over](../scripts/README.md).
   - A Bitwarden item `vps/<name>` with the custom fields listed in `secrets.env.example`.

   ## Install

   ```bash
   projects/<name>/install.sh
   ```

   ## Configure

   ```bash
   projects/<name>/configure.sh
   ```

   ## Run

   ```bash
   sudo cp projects/<name>/systemd/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now <name>
   ```
   ````

## Conventions

- Secrets are never committed — only `*.env.example` manifests are tracked.
- `export-secrets.sh <name>` writes to `./.secrets` by default; pass a second argument to override the destination. Copy it to `~/.config/<name>/.secrets` on the server.
- Keep `install.sh` and `configure.sh` idempotent so they can be re-run safely.

## Updating a project

The repo is the source of truth; the server runs a copy. Changes under
`projects/<name>/` don't take effect until they're synced over and re-applied:

- **Agent instructions** — agenvoy's `persona.md` is re-applied to the session
  with `projects/agenvoy/set-persona.sh <session-id>`. Coddy's `AGENTS.md` is
  installed by its `configure.sh`; re-run it and restart the service.
- **Scripts** — copy the changed script and re-run it.
- **Systemd units** — copy the unit, then `sudo systemctl daemon-reload` and
  `sudo systemctl restart <name>`.

There's no automatic sync. Copy files with `scp`, or clone the repo on the
server and `git pull` (that needs a deploy key or token scoped to this repo).
