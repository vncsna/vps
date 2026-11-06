# Scripts

Repo scripts: server-level setup, run once per server as root, plus the
helper that exports project secrets on your local machine.

## Server setup

### Prerequisites

- A fresh Hetzner server running Debian 12.
- Your SSH public key added to root's `authorized_keys` (Hetzner lets you do this at creation time).

### Usage

```bash
ssh root@<host>
curl -fsSL <this repo>/scripts/setup.sh -o setup.sh
less setup.sh   # review before running
bash setup.sh <user>
```

Or copy the script over and run it directly. `<user>` is required.

### What it does

- Creates a sudo user (with passwordless sudo, since login is key-only) and copies root's SSH key to it.
- Hardens sshd (`PermitRootLogin no`, `PasswordAuthentication no`, `KbdInteractiveAuthentication no`).
- Enables `ufw` (allowing SSH only).
- Installs `fail2ban`, `unattended-upgrades`, and base packages (`git`, `curl`, `jq`, `unzip`, `ca-certificates`), and schedules automatic security upgrades.

After it finishes, log out and back in as the new user. Root SSH is disabled from that point on.

## Secrets

Secrets live in Bitwarden (cloud) and are exported on your local machine, then copied to the server. Nothing secret is committed to this repo, and the server never talks to Bitwarden.

### Vault layout

One Bitwarden item per project, named `vps/<project>` (e.g. `vps/agenvoy`). Each secret is a **custom field** whose name is the environment-variable name (e.g. `OPENROUTER_API_KEY`) and whose value is the secret. Use the "hidden" field type.

### Exporting (on your local machine)

Requires the Bitwarden CLI (`bw`) and `jq` installed locally, and logged in (`bw login`).

```bash
scripts/export-secrets.sh <project> [dest]
```

Fetches the `vps/<project>` item and writes its custom fields as `KEY=value` lines to `dest` (default `./.secrets`).

### Copying to the server

```bash
ssh <user>@<host> 'mkdir -p ~/.config/<project>'
scp .secrets <user>@<host>:~/.config/<project>/.secrets
```

### Rotating a secret

Edit the Bitwarden item, re-export, and re-copy. Done.
