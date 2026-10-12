#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh [username] — initial server setup. Run as root on a fresh Ubuntu.
# Creates a sudo user, hardens sshd, enables ufw, and installs fail2ban,
# unattended-upgrades, and base packages.

USERNAME="${1:-deploy}"

if [[ $EUID -ne 0 ]]; then
  echo "run as root" >&2
  exit 1
fi

# --- user ---
if ! id "$USERNAME" &>/dev/null; then
  adduser --disabled-password --gecos "" "$USERNAME"
  usermod -aG sudo "$USERNAME"
fi

# The account has no password (key-only login), so grant passwordless sudo.
# Without this, `sudo` would prompt for a password that can never be entered.
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/90-$USERNAME"
chmod 440 "/etc/sudoers.d/90-$USERNAME"

# Copy root's authorized_keys to the new user (assumes your key is on root).
if [[ -f /root/.ssh/authorized_keys ]]; then
  install -d -m 700 -o "$USERNAME" -g "$USERNAME" "/home/$USERNAME/.ssh"
  install -m 600 -o "$USERNAME" -g "$USERNAME" \
    /root/.ssh/authorized_keys "/home/$USERNAME/.ssh/authorized_keys"
fi

# --- sshd hardening ---
cat > /etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
EOF
systemctl reload ssh

# --- firewall ---
ufw allow OpenSSH
ufw --force enable

# --- packages ---
apt-get update
apt-get install -y --no-install-recommends \
  fail2ban unattended-upgrades \
  git curl ca-certificates jq unzip

# --- services ---
systemctl enable --now fail2ban
systemctl enable --now unattended-upgrades

echo "done. log in as $USERNAME@<host>"
