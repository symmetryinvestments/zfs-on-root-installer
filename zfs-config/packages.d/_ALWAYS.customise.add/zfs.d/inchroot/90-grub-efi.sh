#
# Install the grub bootloader to an ESP partition
#

# FIXME
# - we assume that part9 is always and only ESP
# - lsblk doesnt find any ESP partitions when run inside the chroot ?!?!
# figure out which partitions are ESP
#PARTS=$(lsblk -r -o "name,parttype" |grep c12a7328-f81f-11d2-ba4b-00a0c93ec93b)

# What is the boot menu name of this distribution
NAME=ubuntu

# A list of all ESP partitions
PARTS_BYID=$(find /dev/disk/by-id/ |grep -- -part9 ||true)

# systems that don't have disk by-id labels (eg: virtio disks)
if [ -z "$PARTS_BYID" ]; then
    PARTS_BYID=$(lsblk -e 2 -e 11 -o NAME -n -r -p |grep 9$ ||true)
fi

if [ -z "$PARTS_BYID" ]; then
    echo ERROR: could not find any ESP partitions
    false
fi

# shellcheck disable=SC2086
# Make sure we have only detected one instance of each ESP partition
PARTS=$(readlink -f $PARTS_BYID |sort |uniq)

echo "Found ESP partitions: $PARTS"

unset FSDEV
unset COPYDEVS
# wipe any remaining superblocks
for i in $PARTS; do
    wipefs -a "$i"
    if [ -z "$FSDEV" ]; then
        FSDEV="$i"
    else
        COPYDEVS+="$i "
    fi
done

mkdosfs -F 32 -n ESP "$FSDEV"
UUID=$(blkid -s UUID -o value "$FSDEV")
if [ -z "$UUID" ]; then
    echo ERROR: could not find UUID of ESP partition
    false
fi
echo "Found ESP partition UUID: $UUID"

# Remove any existing boot entries from the fstab
# (this will only happen if the grub-efi script is being tested)
sed -i -e 's%.* /boot/efi vfat .*%%' /etc/fstab

mkdir -p /boot/efi
echo "UUID=$UUID /boot/efi vfat nofail,x-systemd.device-timeout=1 0 1" >> /etc/fstab
mount /boot/efi

grub-install --target=x86_64-efi --efi-directory=/boot/efi \
    --bootloader-id=$NAME --recheck --no-floppy

# as a belts /and/ suspender aproach - if the efi boot order doesnt find
# the right bootloader, add a shell startup script
#
# The scripts use a path variable to find the commands they execute, which
# is populated automatically by the efishell.  If there is no current
# directory set, then you cannot use a path to your command
echo "bootx64.efi" >"/boot/efi/startup.nsh"
echo "bootx64.efi" >"/boot/efi/$NAME.nsh"

# Ensure all our duplicate ESP devices start out with a working config
for i in $COPYDEVS; do
    mkdosfs -F 32 -n ESPcopy "$i"
    mount "$i" /mnt
    cp -a /boot/efi/* /mnt/
    umount /mnt
done

umount /boot/efi

