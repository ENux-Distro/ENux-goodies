#!/bin/bash

# Must run as root
if [ "$EUID" -ne 0 ]; then
  echo "======================================="
  echo "=   ERROR: phase2.sh must run as root  ="
  echo "======================================="
  exit 1
fi

# Prevent double-running
if [ -f /etc/enux-phase2-done ]; then
  exit 0
fi

clear
echo "========================================"
echo "         ENux PHASE 2 - INSTALLING E's"
echo "========================================"
echo

echo "Fetching Arch..."
brl fetch arch --mirror https://mirror.bytemark.co.uk/archlinux/$repo/os/$arch

echo "Fetching Fedora ..."
brl fetch fedora --release 41

echo "Fetching Void..."
brl fetch void

echo "Fetching Alpine..."
brl fetch alpine

echo "Fetching Gentoo..."
brl fetch gentoo


USER_HOME=$(eval echo "~$SUDO_USER")

# Create logo directory
mkdir -p "$USER_HOME/.config/fastfetch"

# ASCII Logo
cat > "$USER_HOME/.config/fastfetch/E-logo.txt" << 'EOF'
eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee
eeeee
eeeee
eeeeeeeeeeeeeeeeeeeeeeee
eeeee
eeeee
eeeee
eeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee
EOF

chmod 644 "$USER_HOME/.config/fastfetch/E-logo.txt"

# Fastfetch configuration
mkdir -p /etc/fastfetch
cat > /etc/fastfetch/config.jsonc << EOF
{
  "\$schema": "https://fastfetch.dev/json-schema",
  "logo": {
    "type": "file",
    "source": "$USER_HOME/.config/fastfetch/E-logo.txt"
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
EOF

# Command to create the fastfetch configuration file
cat > ~/.config/fastfetch/config.jsonc << 'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
      "type": "file",
      "source": "/home/emir/.config/fastfetch/E-logo.txt"
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
EOF

echo
echo "========================================"
echo "=          ENux 1.0 IS READY!          ="
echo "=         Run: enuxfetch anytime       ="
echo "========================================"
echo

# Mark phase 2 as done
mkdir -p /etc
touch /etc/enux-phase2-done
