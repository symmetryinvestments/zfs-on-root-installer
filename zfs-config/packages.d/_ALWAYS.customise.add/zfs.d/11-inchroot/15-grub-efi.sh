#
# Install the grub bootloader to an EFS partition
#

# FIXME
# - lsblk doesnt find any EFS partitions when run inside the chroot ?!?!
# figure out which partitions are EFS
#PARTS=$(lsblk -r -o "name,parttype" |grep c12a7328-f81f-11d2-ba4b-00a0c93ec93b)

# for now, just take the first part9
PART=$(find /dev/disk/by-id/|grep -- -part9 |head -1)
PARTUUID=$(blkid -s PARTUUID -o value $PART)

mkdosfs -F 32 -n EFS $PART
mkdir -p /boot/efi
echo "PARTUUID=$PARTUUID /boot/efi vfat defaults 0 1" >> /etc/fstab
mount /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi

# TODO
# - need to duplicate this to all other EFS partitions
# - thus should mount it with something other than the PARTUUID
# - could benefit by creating a mirrorset..
# - 
