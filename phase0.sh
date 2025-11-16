#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Search for ENux-goodies in common locations
SEARCH_PATHS=("$HOME" "/opt" "/usr/local/share" "/usr/share")
REPO_PATH=""

for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path/ENux-goodies" ]; then
        REPO_PATH="$path/ENux-goodies"
        break
    fi
done

if [ -z "$REPO_PATH" ]; then
    echo "ENux-goodies folder not found!"
    exit 1
fi

echo "Found ENux-goodies at: $REPO_PATH"

# Scripts inside ENux-goodies
SCRIPTS=("phase1.sh" "phase2.sh")

# Output directory for desktop icons
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$REPO_PATH/$script"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "$script not found!"
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
done

echo "Desktop launchers created in $DESKTOP_DIR!"


