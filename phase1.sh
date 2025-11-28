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

# Phase 2 service (user-level, opens terminal)
mkdir -p /home/enux/.config/systemd/user

cat << 'EOF' > /home/enux/.config/systemd/user/phase2.service
[Unit]
Description=ENux Phase2 Script
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/home/enux/ENux-goodies/phase2.sh
Environment=XDG_CONFIG_DIRS=/etc/xdg:/usr/share/xdg
RemainAfterExit=no

[Install]
WantedBy=default.target
EOF

# Enable for enux user
chown -R enux:enux /home/enux/.config/systemd/user
sudo -u enux systemctl --user enable phase2.service

# ENux black login greeter setup
mkdir -p /usr/share/images/desktop-base
cp /home/enux/ENux-goodies/enux-login.png /usr/share/images/desktop-base/desktop-background
cp /home/enux/ENux-goodies/enux-login.svg /usr/share/images/desktop-base/login-background.svg
sed -i 's|^background=.*|background=/usr/share/images/desktop-base/desktop-background|' /etc/lightdm/lightdm-gtk-greeter.conf


clear
echo "========================================="
echo "=           PHASE 1 COMPLETED           ="
echo "=         REBOOT NOW FOR PHASE 2        ="
echo "=        (E's installed in Phase 2)     ="
echo "========================================="
echo
echo            "Run: sudo reboot"

