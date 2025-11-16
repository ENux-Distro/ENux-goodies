#!/bin/bash
# =========================
# ENux Phase 0 - Desktop Launcher Creator
# =========================

# Ensure we're running in bash
if [ -z "$BASH_VERSION" ]; then
    echo "Please run this script with bash:"
    echo "sudo bash ./phase0.sh"
    exit 1
fi

# Require root for creating desktop files in .local/share/applications
if [ "$EUID" -ne 0 ]; then
    echo "Run this script with sudo:"
    echo "sudo ./phase0.sh"
    exit 1
fi

# Use the current folder as repo path
REPO_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "Using ENux-goodies folder at: $REPO_PATH"

# Scripts to create launchers for
SCRIPTS=("phase1.sh" "phase2.sh")

# Where the desktop files go
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# Loop through scripts
for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "$script not found in $REPO_PATH!"
        continue
    fi

    DESKTOP_FILE="$DESKTOP_DIR/$script.desktop"

    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$script
Comment=Run $script
Exec=$SCRIPT_PATH _class_
Terminal=true
Type=Application
Categories=Utility;
EOF

    chmod +x "$DESKTOP_FILE"
    chmod +x "$SCRIPT_PATH"
    echo "Created launcher for $script at $DESKTOP_FILE"
done

echo "✅ Phase 0 complete! Launchers are in $DESKTOP_DIR"
