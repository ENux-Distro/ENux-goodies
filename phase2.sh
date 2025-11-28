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

#Installing bedrock linux

# Installing Bedrock Linux
echo "Installing ENux core (Bedrock Linux hijack)..."

# Download installer
wget -O /tmp/bedrock-linux-0.7.30-x86_64.sh \
https://github.com/bedrocklinux/bedrocklinux-userland/releases/download/0.7.30/bedrock-linux-0.7.30-x86_64.sh \
|| { echo "ERROR: Failed to download Bedrock!"; exit 1; }

# Make it executable
chmod +x /tmp/bedrock-linux-0.7.30-x86_64.sh

# Run Bedrock installer with auto-confirm
cat << 'EOF' > /tmp/bedrock_auto.expect
#!/usr/bin/expect -f

set timeout -1

# Bedrock installer path
set bedrock "/tmp/bedrock-linux-0.7.30-x86_64.sh"

spawn sh $bedrock --hijack

expect {
    -re "Not reversible!" {
        send "Not reversible!\r"
    }
}

expect eof
EOF

# Make it executable
chmod +x /tmp/bedrock_auto.expect
#Run the script
/tmp/bedrock_auto.expect

