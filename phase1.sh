#!/bin/bash

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

# Create logo file
mkdir -p "$HOME/.config/fastfetch"

cat > "$HOME/.config/fastfetch/E-logo.txt" << 'EOF'
eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee
eeeee
eeeee
eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee
eeeee
eeeee
eeeee
eeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee
EOF

# Create fastfetch config
mkdir -p /etc/fastfetch

cat > /etc/fastfetch/config.jsonc << 'JSON'
{
  "$schema": "https://fastfetch.dev/json-schema",
  "logo": {
    "type": "file",
    "source": "~/.config/fastfetch/E-logo.txt"
  },
  "modules": [
    { "type": "title", "format": "{1}@ENux-Hybrid-Meta_Distro" },
    { "type": "os", "format": "ENux 1.0 x86_64" },
    { "type": "kernel", "format": "linux-6.12.48-enux1-amd64" },
    "uptime",
    "shell",
    "de",
    "memory",
    "display",
    "disk",
    { "type": "packages", "format": "Packages: {1}{2}{3}{4}{5}{6}" }
  ]
}
JSON

# enuxfetch wrapper
cat > /usr/local/bin/enuxfetch << 'WRAP'
#!/bin/bash
fastfetch --config /etc/fastfetch/config.jsonc
WRAP

chmod +x /usr/local/bin/enuxfetch

# enux (apt wrapper)
cat > /usr/local/bin/enux << 'APT'
#!/bin/bash
echo "ENux: Using apt (pre-hijack) / brl (post-hijack)"
apt "$@"
APT

chmod +x /usr/local/bin/enux

echo "Installing ENux core (Bedrock Linux hijack)..."

# Clone bedrock repo
git clone https://github.com/ENux-Distro/bedrock-linux.git /tmp/bedrock-linux

chmod +x /tmp/bedrock-linux/bedrock-linux-0.7.30-x86_64.sh

expect << 'EOF'
spawn sh /tmp/bedrock-linux/bedrock-linux-0.7.30-x86_64.sh --hijack
expect "Not reversible!"
send "Not reversible!\r"
interact
EOF

clear
echo "========================================="
echo "=           PHASE 1 COMPLETED           ="
echo "=         REBOOT NOW FOR PHASE 2        ="
echo "=        (E's installed in Phase 2)     ="
echo "========================================="
echo
echo "Run: sudo reboot"

