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
        if [ "$(readlink "$id")" == "../../$dev" ]; then
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
    lsblk -n -b -d -o NAME,WWN -e 11 -r | while read -r dev wwn; do
        # floppy disks? who has them any more?
        if [ "$dev" == "fd0" ]; then
            continue
        fi

        # if possible, use the WWN name
        dev_wwn="/dev/disk/by-id/wwn-$wwn"
        if [ "$(readlink "$dev_wwn")" == "../../$dev" ]; then
            echo "$dev_wwn"
            continue
        fi

        # next, try the NVME version of a WWN
        dev_wwn="/dev/disk/by-id/nvme-$wwn"
        if [ "$(readlink "$dev_wwn")" == "../../$dev" ]; then
            echo "$dev_wwn"
            continue
        fi

        # No WWN, look for any ID link
        bdev_find_name "$dev"
    done
}

DISKDB=/tmp/diskdb

# Given a disk basename and a key/val, save that
disk_set() {
    local dev="$1"
    local key="$2"
    local val="$3"
    echo "$val" >"$DISKDB/$dev/$key"
}

# Given a disk basename and a key return the val
disk_get() {
    local dev="$1"
    local key="$2"
    local keyfile
    keyfile="$DISKDB/$dev/$key"
    if [ -f "$keyfile" ]; then
        cat "$keyfile"
    fi
}

# Given a full pathname for a disk, create a structure for it
disk__add() {
    local dev="$1"
    local bn
    bn=$(basename "$dev")
    mkdir -p "$DISKDB/$bn"
    disk_set "$bn" dev "$dev"
    disk_set "$bn" size "$(lsblk -n -b -d -o SIZE -r "$dev")"
    disk_set "$bn" rota "$(lsblk -n -b -d -o ROTA -r "$dev")"
    disk_set "$bn" model "$(lsblk -n -b -d -o MODEL -r "$dev")"
}

# Given one or more full pathnames for a disk, create structures for them
disk_add() {
    for i in "$@"; do
        disk__add "$i"
    done
}

# Add all the disks in the system to the DISKDB
disk_add_all() {
    rm -rf "$DISKDB"
    # shellcheck disable=SC2046
    disk_add $(bdev_best_name)
}

# Return a list of all disks in the DISKDB
disk_all() {
    for path in $DISKDB/*; do
        basename "$path"
    done
}

# Given a var/val pair and a list of disks, find the ones that do not match
disk_find_nomatch() {
    local var="$1"
    local val="$2"
    shift 2
    for dev in "$@"; do
        if [ "$(disk_get "$dev" "$var")" != "$val" ]; then
            echo "$dev"
        fi
    done
}

# Given a var/val pair and a list of disks, find the ones that do match
disk_find_match() {
    local var="$1"
    local val="$2"
    shift 2
    for dev in "$@"; do
        if [ "$(disk_get "$dev" "$var")" = "$val" ]; then
            echo "$dev"
        fi
    done
}

# Naive mirror pairing
# Given a list of disks, try to pair them off for mirrorsets
disk_to_pairs() {
    # need to be able to return the list of disk names that have been consumed
    rm -f /tmp/disk_to_pairs.hack
    prev_size=0
    prev_name=none
    for dev in "$@"; do
        size=$(disk_get "$dev" size)

        # FIXME - should allow 5% slop when comparing
        if [ "$size" == "$prev_size" ]; then
            # TODO - assumes "-part1"
            echo "mirror ${prev_name}-part1 ${dev}-part1"
            disk_set "$prev_name" consumed 1
            disk_set "$dev" consumed 1
            echo "$prev_name $dev" >>/tmp/disk_to_pairs.hack
            prev_size=0
            prev_name=none
            continue
        fi
        prev_size="$size"
        prev_name="$dev"
    done
}

# Look through available disks (in DISKDB) and find all the disks suitable for
# using as the ZFS main bulk storage
find_bulk() {
    local disks disks_rota disks_avail
    disks="$(disk_all)"
    # shellcheck disable=SC2086
    disks_rota="$(disk_find_match rota 1 $disks)"

    if [ -n "$disks_rota" ]; then
        disks_avail="$disks_rota"
    else
        # if there are no rotating disks, just try them all
        disks_avail="$disks"
    fi

    # shellcheck disable=SC2086
    # We actually want to do word splitting on this arg
    ZFS_VDEVS="$(disk_to_pairs $disks_avail)"

    if [ -n "$ZFS_VDEVS" ]; then
        # we found some pairs, return with them
        ZFS_PART_BULKBOOT=$(cat /tmp/disk_to_pairs.hack)
        return 0
    fi

    # If we could not pair them off
    # some special cases for the expected places we need this
    case "$disks_avail" in
        vda|sda|hda)
            ZFS_VDEVS=${disks_avail}1
            ZFS_PART_BULKBOOT=$disks_avail
            disk_set "$disks_avail" consumed 1
            ;;
        *)
            ZFS_VDEVS=${disks_avail}-part1
            ZFS_PART_BULKBOOT=$disks_avail
            disk_set "$disks_avail" consumed 1
            ;;
    esac
}

# Look through available disks (in DISKDB) and find something suitable for SLOG
# possibly finding a pair to mirror
find_slog() {
    local disks disks_avail disks_norota model slog

    # shellcheck disable=SC2046
    disks_avail=$(disk_find_nomatch consumed 1 $(disk_all))
    # shellcheck disable=SC2086
    disks_norota=$(disk_find_nomatch rota 1 $disks_avail)

    disks=
    # first, look for "INTEL SSD" - which we assume has power loss prevention
    for dev in $disks_norota; do
        model=$(disk_get "$dev" model)
        case "$model" in
            INTEL*) # FIXME
                disks+=" $dev"
                ;;
        esac
    done
    # shellcheck disable=SC2086
    slog=$(disk_to_pairs $disks)

    if [ -n "$slog" ]; then
        ZFS_VDEVS+=$(echo; echo "log ${slog}")
        ZFS_PART_SLOG="$(cat /tmp/disk_to_pairs.hack)"
        return 0
    fi

    # otherwise, just take the first unused SSD
    for dev in $disks_norota; do
        case "$dev" in
            nvme*)
                # assume NVME is "fastest" at read speed so reserve for cache
                continue
                ;;
        esac
        disk_set "$dev" consumed 1
        ZFS_VDEVS+=$(echo; echo "log ${dev}-part1")
        ZFS_PART_SLOG="$dev"
        return 0
    done
}

# Look through available disks (in DISKDB) and find something fast to use
# as a cache
find_cache() {
    local disks_avail disks_norota

    # shellcheck disable=SC2046
    disks_avail=$(disk_find_nomatch consumed 1 $(disk_all))
    # shellcheck disable=SC2086
    disks_norota=$(disk_find_nomatch rota 1 $disks_avail)

    # first, look for a NVME - which we assume is "fastest" for reading
    for dev in $disks_norota; do
        case "$dev" in
            nvme*)
                disk_set "$dev" consumed 1
                ZFS_VDEVS+=$(echo; echo "cache ${dev}-part1")
                ZFS_PART_CACHE="$dev"
                return 0
                ;;
        esac
    done

    # otherwise, just take the first unused SSD
    for dev in $disks_norota; do
        disk_set "$dev" consumed 1
        ZFS_VDEVS+=$(echo; echo "cache ${dev}-part1")
        ZFS_PART_CACHE="$dev"
        return 0
    done
}

# initialise the database
disk_add_all

find_bulk
find_slog
find_cache

echo
echo "Disks to create full sized data partitions and EFS partitions on:"
echo "$ZFS_PART_BULKBOOT"
echo
echo "Disks to create slog-sized data partitions and use as slog:"
echo "$ZFS_PART_SLOG"
echo
echo "Disks to create cache-sized data partitions and use as cache:"
echo "$ZFS_PART_CACHE"
echo
echo "ZFS Vdevs to create:"
echo "$ZFS_VDEVS"
echo

# TODO
# - better automation of discovery and suggested layout
