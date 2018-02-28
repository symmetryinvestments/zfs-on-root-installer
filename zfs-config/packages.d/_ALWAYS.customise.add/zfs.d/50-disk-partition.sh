#
# Nuke the partition tables on the given disks
#
# Creates two partitions on each disk
# partition 9 is the final 550Meg of the disk and allocated to the ESP
# partition 1 is the remainder of the disk and allocated to ZFS

echo "Will nuke partitions on:"
echo "$ZFS_DISKS"
sleep 5s

for disk in $ZFS_DISKS; do
    sgdisk --zap-all "$disk"
    sgdisk \
        --new=9:-550M:0 --typecode=9:EF00 \
        --largest-new=1 --typecode=1:BF01 \
        "$disk"
done

# FIXME - dont just sleep, wait for the partitions to appear
echo Sleeping for udev to finish discovering and enumerating
sleep 10s

