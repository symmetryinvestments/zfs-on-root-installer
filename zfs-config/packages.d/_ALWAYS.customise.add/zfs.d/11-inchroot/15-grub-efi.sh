#
# Install the grub bootloader to an EFS partition
#

# FIXME
# - need to figure out which partitions are EFS

# for now, just take the first part9
PART=$(find /dev/disk/by-id/|grep -- -part9 |head -1)

mkdosfs -F 32 -n EFS $PART
mkdir /boot/efi
echo PARTUUID=$(blkid -s PARTUUID -o value $PART) /boot/efi vfat defaults 0 1 >> /etc/fstab
mount /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi

# TODO
# - need to duplicate this to all other EFS partitions
# - thus should mount it with something other than the PARTUUID
# - could benefit by creating a mirrorset..

