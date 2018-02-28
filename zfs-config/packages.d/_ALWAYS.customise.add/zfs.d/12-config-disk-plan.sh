#
# Eventually, this script wants to be able to find the disks and create the
# appropriate ZFS pool creation data
#

# Disks:
# we want mirrored pairs
# we want the main ZFS data to reside on spinning rust (SSD for SLOG/Cache)
# we want to have redundant ESP partitions (FIXME - A mirror?)

# Create list of rotational disks
# sort by size, then by connection path
# select into pairs of same sized disks (within 5% size)

# FIXME - should functions be all in one common place?

# Given the bare name of a block device, output first matching disk/by-id name
bdev_find_name() {
    local dev="$1"
    local id

    for id in /dev/disk/by-id/*; do
        if [ $(readlink $id) == "../../$dev" ]; then
            echo "$id"
            return 0
        fi
    done

    # No ID links, just use /dev name
    echo "/dev/$dev"
    return 0
}

# Output a list of block devs, using the best symbolic name for each
bdev_best_name() {
    lsblk -n -b -d -o NAME,WWN -e 11 -r | while read dev wwn; do
        # floppy disks? who has them any more?
        if [ "$dev" == "fd0" ]; then
            continue
        fi

        # if possible, use the WWN name
        dev_wwn="/dev/disk/by-id/wwn-$wwn"
        if [ "$(readlink $dev_wwn)" == "../../$dev" ]; then
            echo "$dev_wwn"
            continue
        fi

        # next, try the NVME version of a WWN
        dev_wwn="/dev/disk/by-id/nvme-$wwn"
        if [ "$(readlink $dev_wwn)" == "../../$dev" ]; then
            echo "$dev_wwn"
            continue
        fi

        # No WWN, look for any ID link
        bdev_find_name "$dev"
    done
}

# Given a list of block devs, output only the rotational ones
bdev_only_rotating() {
    for dev in $*; do
        if [ "$(lsblk -n -b -d -o ROTA -r $dev)" == "1" ]; then
            echo $dev
        fi
    done
}

# Naive mirror pairing
# Given a list of block devs, try to pair them off for mirrorsets
bdev_to_pairs() {
    prev_size=0
    prev_name=none
    for dev in $*; do
        size=$(lsblk -n -b -d -o SIZE -r "$dev")

        # FIXME - should allow 5% slop when comparing
        if [ "$size" == "$prev_size" ]; then
            # TODO - assumes "-part1"
            echo "mirror ${prev_name}-part1 ${dev}-part1"
            prev_size=0
            prev_name=none
            continue
        fi
        prev_size="$size"
        prev_name="$dev"
    done
}

BDEV="$(bdev_best_name)"

ZFS_DISKS="$(bdev_only_rotating $BDEV)"

# if there are no rotating disks, just try them all
if [ -z "$ZFS_DISKS" ]; then
    ZFS_DISKS="$BDEV"
fi

ZFS_VDEVS="$(bdev_to_pairs $ZFS_DISKS)"

# If we could not pair them off
if [ -z "$ZFS_VDEVS" ]; then
    # some special cases for the expected places we need this
    case "$ZFS_DISKS" in
        /dev/vda)
            ZFS_VDEVS=${ZFS_DISKS}1 ;;
        /dev/disk/by-id/*)
            ZFS_VDEVS=${ZFS_DISKS}-part1 ;;
    esac
fi

echo
echo "Disks to create full sized data partitions and EFS partitions on:"
echo "$ZFS_DISKS"
echo
echo "ZFS Vdevs to create:"
echo "$ZFS_VDEVS"
echo

# TODO
# - better automation of discovery and suggested layout
