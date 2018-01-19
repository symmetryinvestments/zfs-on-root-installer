#
# Install the grub bootloader to an EFS partition
#

# FIXME
# - lsblk doesnt find any EFS partitions when run inside the chroot ?!?!
# figure out which partitions are EFS
#PARTS=$(lsblk -r -o "name,parttype" |grep c12a7328-f81f-11d2-ba4b-00a0c93ec93b)

# for now, just take the first part9
PART=$(find /dev/disk/by-id/|grep -- -part9 |head -1)

# systems that don't have disk id labels (eg: a virtio disks)
if [ -z "$PART" ]; then
    PART=$(lsblk -d -e 2 -e 11 -o NAME -n |grep 9$ |head -1)
fi

if [ -z "$PART" ]; then
    echo ERROR: could not find EFS partition
    false
fi
echo Found EFS partition: $PART

wipefs -a $PART
mkdosfs -F 32 -n EFS $PART
UUID=$(blkid -s UUID -o value $PART)
if [ -z "$UUID" ]; then
    echo ERROR: could not find UUID of EFS partition
    false
fi
echo Found EFS partition UUID: $UUID

mkdir -p /boot/efi
echo "UUID=$UUID /boot/efi vfat defaults 0 1" >> /etc/fstab
mount /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi

# TODO
# - need to duplicate this to all other EFS partitions
# - thus should mount it with something other than the PARTUUID
# - could benefit by creating a mirrorset..
# - 
