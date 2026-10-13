# vps

A framework for provisioning and running self-hosted projects on a VPS.

The repo is a "home base" for a server: a one-time setup, a shared secrets layer, and a `projects/` directory where each project lives as a self-contained folder.

## Layout

```
setup/         server-level setup — run once per server
secrets/       local secrets export helper (secrets are copied to the server, never fetched there)
projects/      one folder per project (self-contained install/configure/systemd)
docs/          conventions and how-tos
```

## Concepts

- **Setup** hardens the server and installs base packages. Every project assumes it ran first.
- **Secrets** live in a secrets manager (one vault item per project, named `vps/<project>`). `secrets/export-secrets.sh <project>` exports them on your local machine as a `KEY=value` file, which you copy to the server. Nothing secret is ever committed, and the server never talks to the secrets manager.
- **Projects** are folders under `projects/` with their own `install.sh`, `configure.sh`, `secrets.env.example`, and `systemd/` units.

## Quick start

1. Create a server (Debian 12) and add your SSH key to root.
2. `ssh root@<host>` and run `setup/setup.sh <user>`.
3. Export the project's secrets locally and copy them over (see [secrets](secrets/)).
4. Follow a project's `README.md` (e.g. `projects/<project>/`).

## Adding a project

See [docs/adding-a-project.md](docs/adding-a-project.md).

## Security

See [docs/security.md](docs/security.md).
