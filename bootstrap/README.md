# Bootstrap

Server-level setup, run once per server as root.

## Prerequisites

- A fresh Hetzner server running Debian 12.
- Your SSH public key added to root's `authorized_keys` (Hetzner lets you do this at creation time).

## Usage

```bash
ssh root@<host>
curl -fsSL <this repo>/bootstrap/bootstrap.sh | bash -s -- <username>
```

Or copy the script over and run it directly. `<username>` defaults to `deploy`.

## What it does

- Creates a sudo user (with passwordless sudo, since login is key-only) and copies root's SSH key to it.
- Hardens sshd (`PermitRootLogin no`, `PasswordAuthentication no`).
- Enables `ufw` (allowing SSH only).
- Installs `fail2ban`, `unattended-upgrades`, and base packages (`git`, `curl`, `jq`, `unzip`, `ca-certificates`).

After it finishes, log out and back in as the new user. Root SSH is disabled from that point on.
