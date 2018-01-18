#
# Install some basic packages needed for all systems
#

apt update
apt install --yes linux-image-generic wget vim \
    zfs-initramfs dosfstools grub-efi-amd64

