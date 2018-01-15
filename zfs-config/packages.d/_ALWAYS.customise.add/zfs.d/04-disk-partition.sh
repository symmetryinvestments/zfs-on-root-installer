#
# Nuke the partition tables on the given disks
#
# Creates two partitions on each disk
# partition 9 is the final 550Meg of the disk and allocated to the EFS
# partition 1 is the remainder of the disk and allocated to ZFS

for disk in $ZFS_DISKS; do
    sgdisk -Z $disk
    sgdisk -n9:-550M:0 -t9:C12A7328-F81F-11D2-BA4B-00A0C93EC93B -N1 -t1:BF01 $disk
done


