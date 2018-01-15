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

echo "Please use /dev/disk/by-id/wwn* style names"
echo "Pairs should be prefixed with the aggregate style ('mirror' normally)"
echo
lsblk -o "NAME,LABEL,MODEL,SIZE,WWN"
echo
read -p "Disks to Nuke: " -e ZFS_DISKS
read -p "Pair1: " -e ZFS_PAIR1
read -p "Pair2: " -e ZFS_PAIR2
read -p "Pair3: " -e ZFS_PAIR3

# TODO
# - ensure that /dev/disk/by-id/wwn* style names are used for the ZFS_PAIRn
# - ensure that the ZFS_PAIRn has a prefix of "mirror"


