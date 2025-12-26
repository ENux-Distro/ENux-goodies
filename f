#!/bin/bash

# Enable debug and log everything
exec > >(tee /tmp/bootloader-config.log) 2>&1
set -e
set -x

# Detect Calamares target root
CHROOT=$(mount | grep proc | grep calamares | awk '{print $3}' | sed -e "s#/proc##g")

if [ -z "$CHROOT" ]; then
    echo "ERROR: Could not detect Calamares target root!"
    exit 1
fi

echo "Target root detected at: $CHROOT"

# Ensure PATH includes sbin directories
export PATH=$PATH:/usr/sbin:/sbin

# Install LUKS utilities if the target uses encryption
if mount | grep -q "$CHROOT" | grep -q "/dev/mapper/luks"; then
    echo "Configuring LUKS initramfs permissions..."
    echo "UMASK=0077" > "$CHROOT/etc/initramfs-tools/conf.d/initramfs-permissions"
    chroot "$CHROOT" apt-get update
    chroot "$CHROOT" apt-get -y install cryptsetup-initramfs cryptsetup keyutils
fi

echo "Installing bootloader..."

# Ensure required packages exist
chroot "$CHROOT" apt-get update
chroot "$CHROOT" apt-get -y install os-prober

if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI detected, installing grub-efi..."
    chroot "$CHROOT" apt-get -y install grub-efi
else
    echo "BIOS detected, installing grub-pc..."
    chroot "$CHROOT" apt-get -y install grub-pc
fi

# Re-enable os-prober
if [ -f "$CHROOT/etc/default/grub" ]; then
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/# OS_PROBER re-enabled by ENux Calamares installation:\nGRUB_DISABLE_OS_PROBER=false/g' "$CHROOT/etc/default/grub"
fi

# Run update-grub using full path
chroot "$CHROOT" /usr/sbin/update-grub

echo "Bootloader configuration completed successfully!"
