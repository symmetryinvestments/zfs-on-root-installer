#
# Attempt a full TRIM or DISCARD on any disk we will be zapping
#

echo "Will nuke data on:"
echo "$ZFS_PART_BULKBOOT $ZFS_PART_CACHE $ZFS_PART_SLOG"
echo
sleep 5s

for dev in $ZFS_PART_BULKBOOT $ZFS_PART_CACHE $ZFS_PART_SLOG; do
    disk=$(disk_get "$dev" dev)
    blkdiscard "$disk" || true
done
