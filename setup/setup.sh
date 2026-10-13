#!/usr/bin/env bash
set -euo pipefail

# setup.sh [username] — initial server setup. Run as root on a fresh Debian.
# Creates a sudo user, hardens sshd, enables ufw, and installs fail2ban,
# unattended-upgrades, and base packages.

USERNAME="${1:-<user>}"

if [[ $EUID -ne 0 ]]; then
  echo "run as root" >&2
  exit 1
fi

# Fail loudly if there's no key to hand off to the new user. Without this, the
# sshd hardening below would disable root + password login with no working key
# left, locking out all SSH access (see docs/ssh-username-mismatch.md).
if [[ ! -s /root/.ssh/authorized_keys ]]; then
  echo "error: /root/.ssh/authorized_keys is missing or empty." >&2
  echo "add your SSH public key to root before running this script." >&2
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

# Copy root's authorized_keys to the new user (verified non-empty above).
install -d -m 700 -o "$USERNAME" -g "$USERNAME" "/home/$USERNAME/.ssh"
install -m 600 -o "$USERNAME" -g "$USERNAME" \
  /root/.ssh/authorized_keys "/home/$USERNAME/.ssh/authorized_keys"

# Verify the handoff before disabling root login.
if [[ ! -s "/home/$USERNAME/.ssh/authorized_keys" ]]; then
  echo "error: failed to copy authorized_keys to $USERNAME" >&2
  exit 1
fi

# --- sshd hardening ---
cat > /etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
EOF
systemctl reload ssh

# --- packages ---
apt-get update
apt-get install -y --no-install-recommends \
  ufw fail2ban unattended-upgrades python3-systemd \
  git curl ca-certificates jq unzip

# --- firewall ---
ufw allow OpenSSH
ufw --force enable

# --- fail2ban: read sshd logs from the journal (no rsyslog on Debian 12) ---
printf '[sshd]\nbackend = systemd\n' > /etc/fail2ban/jail.d/sshd-backend.conf

# --- services ---
systemctl enable --now fail2ban
systemctl enable --now unattended-upgrades

echo "done. log in as $USERNAME@<host>"
