#!/bin/bash

# Auto-chmod on first run
if [ ! -x "$0" ]; then
    chmod +x "$0"
    exec "$0"
fi

# Detect where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Try to find ENux-goodies repo on the system
REPO_PATH=$(find "$HOME" -type d -name "ENux-goodies" 2>/dev/null | head -n 1)

if [ -z "$REPO_PATH" ]; then
    echo "ENux-goodies folder not found!"
    exit 1
fi

echo "Found ENux-goodies at: $REPO_PATH"

# List of scripts inside ENux-goodies
SCRIPTS=("phase1.sh" "phase2.sh")

for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "$script not found in repo!"
        continue
    fi

    # Create .desktop launcher in the same folder as phase0.sh
    DESKTOP_FILE="$SCRIPT_DIR/$script.desktop"
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$script
Comment=Run $script
Exec=$SCRIPT_PATH
Terminal=true
Type=Application
Categories=Utility;
EOF

    chmod +x "$DESKTOP_FILE"
    chmod +x "$SCRIPT_PATH"
done

echo "Desktop launchers created in $SCRIPT_DIR!"

