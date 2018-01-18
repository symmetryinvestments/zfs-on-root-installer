#
# Eventually, this script wants to be able to find the disks and create the
# appropriate ZFS pool creation data
#
# For now, just prompt the user
#

# Disks:
# we want mirrored pairs
# we want the main ZFS data to reside on spinning rust (SSD for SLOG/Cache)
# we want to have redundant EFS partitions (FIXME - A mirror?)

# Create list of rotational disks
# sort by size, then by connection path
# select into pairs of same sized disks (within 5% size)

echo "FIXME - this is terribly manual, in the future it will not be"
echo ""
echo "Please use /dev/disk/by-id/wwn-0x*-part1 style names"
echo "Each pair line will be turned into a mirror set"
echo
lsblk -o "NAME,LABEL,MODEL,SIZE,WWN"

ROTATIONAL=
pushd /sys/block
for dev in *; do
    case "$dev" in
        loop*|sr*|fd*) ;;
        *)
            if [ $(cat "$dev/queue/rotational") == '1' ]; then
                ROTATIONAL+=" $dev"
            fi
            ;;
    esac
done
popd
echo ROTATIONAL=$ROTATIONAL

ROTATIONAL_WWN=
for dev in $ROTATIONAL; do
    for id in /dev/disk/by-id/wwn-*; do
        if [ $(readlink $id) == "../../$dev" ]; then
            ROTATIONAL_WWN+=" $id"
        fi
    done
    # TODO - what if there is no wwn?
done
echo ROTATIONAL_WWN=$ROTATIONAL_WWN

echo
read -p "Pair1: " -e ZFS_PAIR1
read -p "Pair2: " -e ZFS_PAIR2
read -p "Pair3: " -e ZFS_PAIR3

ZFS_DISKS="$ZFS_PAIR1 $ZFS_PAIR2 $ZFS_PAIR3"

for dev in $ZFS_DISKS; do
    if [ ! -e "$dev" ]; then
        echo "ERROR: $dev does not exist"
        exit 1
    fi

    case "$dev" in
        /dev/disk/by-id/wwn-*)
            ;;
        *)
            echo "WARNING: $dev is not a WWN"
            ;;
    esac
done

# TODO
# - ensure that /dev/disk/by-id/wwn* style names are used for the ZFS_PAIRn
#   unless one does not exist
# - automate discovery and suggested layout..


