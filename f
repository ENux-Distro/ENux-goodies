#!/bin/bash
set -xe
trap 'echo "ERROR: Command failed -> $BASH_COMMAND"' ERR

CHROOT="${INSTALL_ROOT:-/target}"

# 1. Enhanced Bind Mounts
# Added /run (crucial for udev/grub) and /dev/pts
for dir in proc sys dev dev/pts run; do
    mkdir -p "$CHROOT/$dir"
    mountpoint -q "$CHROOT/$dir" || mount --bind "/$dir" "$CHROOT/$dir"
done

# 2. Fix EFI Variable Access
if [ -d /sys/firmware/efi/efivars ]; then
    mount -t efivarfs none "$CHROOT/sys/firmware/efi/efivars" 2>/dev/null || true
fi

export PATH=$PATH:/usr/sbin:/sbin

# 3. Handle Bedrock "Stratum" context
# If you are in a hijacked environment, you might need to ensure 
# the chroot uses the 'global' or 'host' tools.
chroot "$CHROOT" apt-get update

# ... [LUKS Logic remains the same] ...

# 4. Explicit GRUB Installation
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI detected..."
    chroot "$CHROOT" apt-get -y install grub-efi-amd64
    # Manually trigger grub-install to ensure it points to the right place
    chroot "$CHROOT" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ENux --recheck
else
    echo "BIOS detected..."
    chroot "$CHROOT" apt-get -y install grub-pc
    # Note: You may need to specify the device here, e.g., /dev/sda
    # chroot "$CHROOT" grub-install /dev/sdX 
fi

# Update GRUB
if [ -x "$CHROOT/usr/sbin/update-grub" ]; then
    chroot "$CHROOT" update-grub
fi

echo "Bootloader configuration completed!"


