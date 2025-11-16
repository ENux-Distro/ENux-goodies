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

chmod +x /usr/local/bin/enuxfetch

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
cd ENux-goodies

clear
echo "========================================="
echo "=           PHASE 1 COMPLETED           ="
echo "=         REBOOT NOW FOR PHASE 2        ="
echo "=        (E's installed in Phase 2)     ="
echo "========================================="
echo
echo            "Run: sudo reboot"

