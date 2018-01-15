#
# Create the initial zpool
#

ROOT_POOL=zpool

zpool create -f \
    -O atime=off \
    -o ashift=12 \
    -O canmount=off \
    -O compression=lz4 \
    -O normalization=formD \
    -O mountpoint=/ \
    -R /mnt \
    $RPOOL \
    $ZFS_PAIR1 \
    $ZFS_PAIR2 \
    $ZFS_PAIR3



