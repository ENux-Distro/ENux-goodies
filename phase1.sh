#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_PATH="$SCRIPT_DIR"

# Require root
if [ "$EUID" -ne 0 ]; then
  clear
  echo "========================================"
  echo "=   ERROR: ENux PHASE 1 REQUIRES ROOT  ="
  echo "========================================"
  echo
  echo "Run this script with: sudo ./phase1.sh"
  echo
  exit 1
fi

clear
echo "================================================"
echo "=               Welcome to                     ="
echo "=     ENux Installation Phase 1 for Debian     ="
echo "================================================"
echo

echo "Installing necessary tools..."
apt update -y && apt upgrade -y
apt install -y fastfetch git wget curl expect

# Create enuxfetch wrapper
cat << 'EOF' >> ~/.bashrc

enuxfetch() {
    fastfetch "$@"
}

EOF
source ~/.bashrc

# Create ENux apt wrapper
cat > /usr/local/bin/enux << 'APT'
#!/bin/bash
apt "$@"
APT

chmod +x /usr/local/bin/enux

# Installing Bedrock Linux
echo "Installing ENux core (Bedrock Linux hijack)..."

# Download installer
wget -O /tmp/bedrock-linux-0.7.30-x86_64.sh \
https://github.com/bedrocklinux/bedrocklinux-userland/releases/download/0.7.30/bedrock-linux-0.7.30-x86_64.sh \
|| { echo "ERROR: Failed to download Bedrock!"; exit 1; }

# Make it executable
chmod +x /tmp/bedrock-linux-0.7.30-x86_64.sh

# Run Bedrock installer with auto-confirm
cd /tmp/
sh ./bedrock-linux-0.7.30-x86_64.sh --hijack
cd ~

# Create a one-shot systemd service for phase2.sh
cat << 'EOF' > /etc/systemd/system/phase2.service
[Unit]
Description=ENux Phase2 Script
After=graphical.target
Wants=graphical.target

[Service]
Type=oneshot
ExecStart=/home/enux/ENux-goodies/phase2.sh
RemainAfterExit=no
ExecStartPost=/bin/systemctl disable phase2.service
ExecStartPost=/bin/rm -f /etc/systemd/system/phase2.service

[Install]
WantedBy=default.target
EOF

# Enable the service so it runs on next boot
systemctl enable phase2.service


clear
echo "========================================="
echo "=           PHASE 1 COMPLETED           ="
echo "=         REBOOT NOW FOR PHASE 2        ="
echo "=        (E's installed in Phase 2)     ="
echo "========================================="
echo
echo            "Run: sudo reboot"

