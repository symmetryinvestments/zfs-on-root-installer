#
# Create the initial zpool
#

export CONFIG_POOL=tank



zpool create -f \
    -O atime=off \
    -o ashift=12 \
    -O canmount=off \
    -O compression=lz4 \
    -O normalization=formD \
    -O mountpoint=/ \
    -R /mnt \
    $ROOT_POOL \
    $ZFS_VDEVS



