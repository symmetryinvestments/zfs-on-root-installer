#
# Nuke the partition tables on the given disks
#

# TODO
# - perhaps the sizes of these things should be CONFIG vars?

# cache partitions
# "1GB of ARC(in ram) per 5GB of L2ARC"
total_ram=$(grep MemTotal: /proc/meminfo |awk -- '{print $2}')
size_cache="$((total_ram*5 /2))K"

# Separate Log partitions
# "4x10GB would require 25GB"
size_slog=25G

echo "Will nuke partitions on:"
echo "$ZFS_PART_BULKBOOT $ZFS_PART_CACHE $ZFS_PART_SLOG"
echo
echo "Cache size = $size_cache"
echo "SLOG size = $size_slog"
sleep 5s

for dev in $ZFS_PART_BULKBOOT $ZFS_PART_CACHE $ZFS_PART_SLOG; do
    disk=$(disk_get "$dev" dev)
    echo "Zapping $disk"
    sgdisk --zap-all "$disk" || true
done

# bootable bulk data partitions
# Creates two partitions on each disk
# partition 9 is the final 550Meg of the disk and allocated to the ESP
# partition 1 is the remainder of the disk and allocated to ZFS
for dev in $ZFS_PART_BULKBOOT; do
    disk=$(disk_get "$dev" dev)
    sgdisk \
        --new=9:-550M:0 --typecode=9:EF00 \
        --largest-new=1 --typecode=1:BF01 \
        "$disk"
done

# cache partitions
for dev in $ZFS_PART_CACHE; do
    disk=$(disk_get "$dev" dev)
    if ! sgdisk --new=1:0:+$size_cache --typecode=1:BF01 "$disk"; then

        # error creating partition, perhaps we tried to create one too big
        # try again, just asking for the largest possible
        sgdisk --largest-new=1 --typecode=1:BF01
    fi
done

# Separate Log partitions
for dev in $ZFS_PART_SLOG; do
    disk=$(disk_get "$dev" dev)
    sgdisk --new=1:0:+$size_slog --typecode=1:BF01 "$disk"
done

# FIXME - dont just sleep, wait for the partitions to appear
echo Sleeping for udev to finish discovering and enumerating
sleep 10s

