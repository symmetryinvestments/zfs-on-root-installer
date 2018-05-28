#
# Check the various ZFS environment variables and confirm that we actually
# seem to have detected or configured some disks
#

if [ -z "$ZFS_PART_BULKBOOT" ]; then
    echo "No disks detected or configured for bulk storage of ZFS data"
    echo "This is an invalid configuration"
    echo
    echo
    false
    exit
fi
