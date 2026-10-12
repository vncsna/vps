# vps

Instructions and scripts for setting up and running projects on a personal Hetzner VPS.

The repo is a "home base" for the server: a one-time bootstrap, a shared Bitwarden-backed secrets layer, and a `projects/` directory where each project lives as a self-contained folder. The first project is [agenvoy](projects/agenvoy/), a personal knowledge-management agent.

## Layout

```
bootstrap/     server-level setup — run once per server
secrets/       Bitwarden CLI install, login, and a generic secret sync helper
projects/      one folder per project (self-contained install/configure/systemd)
docs/          conventions and how-tos
```

## Concepts

- **Bootstrap** hardens the server and installs base packages. Every project assumes it ran first.
- **Secrets** live in Bitwarden (one vault item per project, named `vps/<project>`). `secrets/sync-secrets.sh <project>` fetches them and writes a local `KEY=value` file the project reads. Nothing secret is ever committed.
- **Projects** are folders under `projects/` with their own `install.sh`, `configure.sh`, `secrets.env.example`, and `systemd/` units.

## Quick start

1. Create a Hetzner server (Ubuntu 24.04 LTS) and add your SSH key to root.
2. `ssh root@<host>` and run `bootstrap/bootstrap.sh [username]`.
3. Log back in as that user, then run `secrets/install-bw.sh` and `secrets/login-bw.sh`.
4. Follow a project's `README.md` (e.g. [projects/agenvoy](projects/agenvoy/)).

## Adding a project

See [docs/adding-a-project.md](docs/adding-a-project.md).
