#!/bin/bash
# =========================
# ENux Phase 0 - Desktop Launcher Creator
# =========================

# Ensure we're running in bash and as root
if [ -z "$BASH_VERSION" ]; then exit 1; fi
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run this script with sudo."
    exit 1
fi

# 1. FIND THE PRIMARY USER (UID >= 1000, not nobody)
TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)

if [ -z "$TARGET_USER" ]; then
    echo "ERROR: Could not find a non-root user (UID >= 1000). Skipping desktop creation."
    exit 1
fi

# Get the home directory of the user
TARGET_HOME=$(eval echo "~$TARGET_USER")
echo "Targeting user: $TARGET_USER ($TARGET_HOME)"

# Use the current folder as repo path (where this script resides)
REPO_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "Using ENux-goodies folder at: $REPO_PATH"

# Scripts to create launchers for
SCRIPTS=("phase1.sh" "phase2.sh")

# Location for desktop files in user home
DESKTOP_DIR="$TARGET_HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# Loop and create desktop files
for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "ERROR: $script not found in $REPO_PATH! Skipping."
        continue
    fi

    DESKTOP_FILE="$DESKTOP_DIR/$script.desktop"

    # Create .desktop file content and install pkexec
    apt-get -y polkitd pkexec
    

for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"
    DESKTOP_FILE="$DESKTOP_DIR/$script.desktop"

    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=ENux Script (Root)
Comment=Run ENux script in terminal as root
Exec=pkexec xfce4-terminal -e "$SCRIPT_PATH"
Terminal=false
Icon=utilities-terminal
Categories=Utility;
EOF

    chmod +x "$DESKTOP_FILE" "$SCRIPT_PATH"
    chown "$TARGET_USER:$TARGET_USER" "$DESKTOP_FILE" "$SCRIPT_PATH"
done

echo "✅ Phase 0 complete! Launchers are in $DESKTOP_DIR for user $TARGET_USER."

exit 0
 
