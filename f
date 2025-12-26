#!/bin/bash

# Enable debug and logging
exec > >(tee /tmp/bootloader-config.log) 2>&1
set -e
set -x

# Detect target root (Calamares sets INSTALL_ROOT)
CHROOT="${INSTALL_ROOT:-/target}"

# Verify the target root exists
if [ ! -d "$CHROOT" ]; then
    echo "ERROR: Target root not found at $CHROOT"
    exit 1
fi

echo "Target root detected at: $CHROOT"

# Bind-mount /proc, /sys, /dev if not already mounted
mount --bind /proc "$CHROOT/proc" || true
mount --bind /sys "$CHROOT/sys" || true
mount --bind /dev "$CHROOT/dev" || true

# Ensure PATH includes sbin directories
export PATH=$PATH:/usr/sbin:/sbin

# Install LUKS utilities if full-disk encryption is used
if mount | grep -q "$CHROOT" | grep -q "/dev/mapper/luks"; then
    echo "Configuring LUKS initramfs permissions..."
    echo "UMASK=0077" > "$CHROOT/etc/initramfs-tools/conf.d/initramfs-permissions"
    chroot "$CHROOT" apt-get update
    chroot "$CHROOT" apt-get -y install cryptsetup-initramfs cryptsetup keyutils
fi

# Install bootloader dependencies
chroot "$CHROOT" apt-get update
chroot "$CHROOT" apt-get -y install os-prober

# Detect UEFI vs BIOS
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI detected, installing grub-efi..."
    chroot "$CHROOT" apt-get -y install grub-efi
else
    echo "BIOS detected, installing grub-pc..."
    chroot "$CHROOT" apt-get -y install grub-pc
fi

# Re-enable os-prober in grub configuration
if [ -f "$CHROOT/etc/default/grub" ]; then
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/# OS_PROBER re-enabled by ENux Calamares installation:\nGRUB_DISABLE_OS_PROBER=false/g' "$CHROOT/etc/default/grub"
fi

# Run update-grub using full path
chroot "$CHROOT" /usr/sbin/update-grub

echo "Bootloader configuration completed successfully!"

