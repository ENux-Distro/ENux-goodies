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
  echo "Phase 2 already done. Skipping."
  exit 0
fi

clear
echo "========================================"
echo "        ENux PHASE 2 - SYSTEM SETUP"
echo "========================================"
echo

###########################################
# 1. FETCH DISTROS USING BEDROCK-LINUX (brl)
###########################################

echo "[+] Fetching Arch Linux..."
brl fetch arch || true

echo "[+] Fetching Fedora 41..."
brl fetch fedora --release 41 || true

echo "[+] Fetching Void..."
brl fetch void || true

echo "[+] Fetching Alpine..."
brl fetch alpine || true

echo "[+] Fetching Gentoo..."
brl fetch gentoo || true

echo
echo "[+] Fetch operations completed (errors ignored)."
echo

#################################################
# 2. PREPARE FASTFETCH CONFIGS (USER + SYSTEM)
#################################################

# Directory for system-wide fastfetch config
mkdir -p /etc/fastfetch

# Directory for user template (copied to new users)
mkdir -p /etc/skel/.config/fastfetch

# ASCII E Logo (saved in skel + system)
cat > /etc/skel/.config/fastfetch/E-logo.txt << 'EOF'
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

cp /etc/skel/.config/fastfetch/E-logo.txt /etc/fastfetch/E-logo.txt
chmod 644 /etc/fastfetch/E-logo.txt

##############################################
# 3. SYSTEM-WIDE FASTFETCH CONFIG (/etc)
##############################################
cat > /etc/fastfetch/config.jsonc << EOF
{
  "\$schema": "https://fastfetch.dev/json-schema",
  "logo": {
    "type": "file",
    "source": "/etc/fastfetch/E-logo.txt"
  },
  "modules": [
    { "type": "title", "format": "{1}@ENux-Hybrid-Meta_Distro" },
    { "type": "os", "format": "ENux 2.0 x86_64" },
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

##############################################
# 4. USER TEMPLATE FASTFETCH CONFIG (/etc/skel)
##############################################
cat > /etc/skel/.config/fastfetch/config.jsonc << EOF
{
  "\$schema": "https://fastfetch.dev/json-schema",
  "logo": {
    "type": "file",
    "source": "\$HOME/.config/fastfetch/E-logo.txt"
  },
  "modules": [
    { "type": "title", "format": "{1}@ENux-Hybrid-Meta_Distro" },
    { "type": "os", "format": "ENux 2.0 x86_64" },
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


##############################################
# 5. DONE
##############################################

echo
echo "========================================"
echo "=        ENux 2.0 IS NOW READY!        ="
echo "=   Fastfetch is fully configured.     ="
echo "=     ENux fetchers installed.         ="
echo "========================================"
echo

# Mark phase 2 as done
touch /etc/enux-phase2-done

