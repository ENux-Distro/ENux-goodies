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

# 1. FIND THE PRIMARY USER
# We look for the first non-root, non-system user (UID >= 1000)
# This assumes the Debian installer created at least one user.
TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)

if [ -z "$TARGET_USER" ]; then
    echo "ERROR: Could not find a non-root user (UID >= 1000). Skipping desktop creation."
    exit 1
fi

# Get the target user's home directory
TARGET_HOME=$(eval echo "~$TARGET_USER")
echo "Targeting user: $TARGET_USER ($TARGET_HOME)"

# Use the current folder as repo path
REPO_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "Using ENux-goodies folder at: $REPO_PATH"

# Scripts to create launchers for
SCRIPTS=("phase1.sh" "phase2.sh")

# Where the desktop files go
DESKTOP_DIR="$TARGET_HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# Loop through scripts
for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "ERROR: $script not found in $REPO_PATH! Skipping."
        continue
    fi

    DESKTOP_FILE="$DESKTOP_DIR/$script.desktop"

    # Create the .desktop file
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$script
Comment=Run $script
Exec=$SCRIPT_PATH
Terminal=true
Type=Application
Categories=Utility;
EOF

    # Set permissions:
    chmod +x "$DESKTOP_FILE"
    chmod +x "$SCRIPT_PATH"
    
    # CRITICAL: Change ownership so the user can see and use the files
    chown -R $TARGET_USER:$TARGET_USER "$DESKTOP_DIR"
    chown $TARGET_USER:$TARGET_USER "$DESKTOP_FILE"

    echo "Created launcher for $script at $DESKTOP_FILE"
done

echo "✅ Phase 0 complete! Launchers are in $DESKTOP_DIR for user $TARGET_USER."

exit 0
