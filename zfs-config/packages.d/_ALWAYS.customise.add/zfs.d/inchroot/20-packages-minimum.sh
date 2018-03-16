#
# Install the minimal packages needed for the rest of the installation
#

PACKAGES+=" linux-image-generic"        # A kernel to boot
PACKAGES+=" zfs-initramfs"              # Infrastructure for booting ZFS
PACKAGES+=" dosfstools grub-efi-amd64"  # Grub and its needed helper
PACKAGES+=" mdadm"                      # tools to manage the ESP mirror
