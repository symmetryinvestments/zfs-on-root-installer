#
# Install some basic packages needed for all systems
#

apt update
apt install --yes --no-install-recommends linux-image-generic wget vim
apt install --yes zfs-initramfs dosfstools grub-efi-amd64

