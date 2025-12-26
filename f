#!/bin/bash

# Enable debug and logging
exec > >(tee /tmp/bootloader-config.log) 2>&1
set -xe
trap 'echo "ERROR: Command failed -> $BASH_COMMAND"' ERR

# Detect target root (Calamares sets INSTALL_ROOT)
CHROOT="${INSTALL_ROOT:-/target}"

# Verify the target root exists
if [ ! -d "$CHROOT" ]; then
    echo "ERROR: Target root not found at $CHROOT"
    exit 1
fi
echo "Target root detected at: $CHROOT"

# Bind-mount /proc, /sys, /dev if not already mounted
for dir in proc sys dev; do
    mountpoint -q "$CHROOT/$dir" || mount --bind "/$dir" "$CHROOT/$dir"
done

# Ensure PATH includes sbin directories
export PATH=$PATH:/usr/sbin:/sbin

# Update chroot's apt
if [ ! -f "$CHROOT/etc/apt/sources.list" ]; then
    echo "ERROR: No sources.list in target root. Cannot install packages."
    exit 1
fi

chroot "$CHROOT" apt-get update || echo "WARNING: apt-get update failed inside chroot"

# Install LUKS utilities if target uses encryption
if mount | grep -q "$CHROOT" | grep -q "/dev/mapper/luks"; then
    echo "Configuring LUKS initramfs permissions..."
    echo "UMASK=0077" > "$CHROOT/etc/initramfs-tools/conf.d/initramfs-permissions"
    chroot "$CHROOT" apt-get -y install cryptsetup-initramfs cryptsetup keyutils || echo "WARNING: LUKS packages failed to install"
fi

# Install bootloader dependencies safely
chroot "$CHROOT" apt-get -y install os-prober || echo "WARNING: os-prober install failed"

# Detect UEFI vs BIOS and install appropriate grub
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI detected, installing grub-efi..."
    chroot "$CHROOT" apt-get -y install grub-efi || echo "WARNING: grub-efi install failed"
else
    echo "BIOS detected, installing grub-pc..."
    chroot "$CHROOT" apt-get -y install grub-pc || echo "WARNING: grub-pc install failed"
fi

# Re-enable os-prober in grub configuration if file exists
if [ -f "$CHROOT/etc/default/grub" ]; then
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/# OS_PROBER re-enabled by ENux Calamares installation:\nGRUB_DISABLE_OS_PROBER=false/g' "$CHROOT/etc/default/grub"
fi

# Run update-grub if /usr/sbin/update-grub exists
if [ -x "$CHROOT/usr/sbin/update-grub" ]; then
    chroot "$CHROOT" /usr/sbin/update-grub || echo "WARNING: update-grub failed"
else
    echo "WARNING: update-grub not found in target root"
fi

echo "Bootloader configuration completed!"


