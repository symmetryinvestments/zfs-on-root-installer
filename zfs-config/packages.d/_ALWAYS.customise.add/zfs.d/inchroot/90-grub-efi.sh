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

# Before trying to create anything, ensure that nothing is using the devices
mdadm --stop --scan

# and wipe any remaining superblocks
for i in $PARTS; do
    wipefs -a "$i"
done

PARTSNR=$(echo "$PARTS" | wc -w)
FSDEV=/dev/md0

# shellcheck disable=SC2086
mdadm --create $FSDEV --metadata=0.90 --level=mirror \
    --raid-devices="$PARTSNR" --force $PARTS
# Note that the --force is here so that we can have a mirror with 1 drive in
# it, which is useful in a test environment and provides a consistant setup
# to production hardware

mkdosfs -F 32 -n ESP "$FSDEV"
UUID=$(blkid -s UUID -o value "$FSDEV")
if [ -z "$UUID" ]; then
    echo ERROR: could not find UUID of ESP partition
    false
fi
echo "Found ESP partition UUID: $UUID"

mkdir -p /boot/efi
echo "UUID=$UUID /boot/efi vfat nofail,x-systemd.device-timeout=1 0 1" >> /etc/fstab
mount /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
    --bootloader-id=$NAME --recheck --no-floppy \
    --no-nvram

# as a belts /and/ suspender aproach - if the efi boot order doesnt find
# the right bootloader, add a shell startup script
echo "\\EFI\\$NAME\\grubx64.efi" >/boot/efi/startup.nsh

umount /boot/efi

# grub-install doesnt cope with a mirror set as the /boot/efi, so it cannot
# work out which bootmgr entry to create.
#
# So, we create that manually here
for i in $PARTS; do
    RAW_PART=$(basename "$i" 9)

    efibootmgr -c \
        -d "/dev/$RAW_PART" \
        -p 9 \
        -w \
        -L "$NAME" \
        -l "\\EFI\\$NAME\\grubx64.efi"
done
