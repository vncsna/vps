# <project>

One-line description of what this project does.

## Prerequisites

- [Bootstrap](../../bootstrap/README.md) done.
- [Secrets exported and copied over](../../secrets/README.md).
- A Bitwarden item `vps/<project>` with the custom fields listed in `secrets.env.example`.

## Install

```bash
projects/<project>/install.sh
```

## Configure

```bash
projects/<project>/configure.sh
```

## Run

```bash
sudo cp projects/<project>/systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now <project>
```
