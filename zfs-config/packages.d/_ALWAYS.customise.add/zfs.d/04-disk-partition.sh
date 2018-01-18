#
# Nuke the partition tables on the given disks
#
# Creates two partitions on each disk
# partition 9 is the final 550Meg of the disk and allocated to the EFS
# partition 1 is the remainder of the disk and allocated to ZFS

echo "Will nuke partitions on $ZFS_DISKS"
sleep 5s

for disk in $ZFS_DISKS; do
    sgdisk -Z $disk
    sgdisk -n9:-550M:0 -t9:EF00 -N1 -t1:BF01 $disk
done

# FIXME - dont just sleep, wait for the partitions to appear
echo Sleeping for udev to finish discovering and enumerating
sleep 10s

