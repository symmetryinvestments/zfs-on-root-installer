#
# Create the initial zpool
#

# TODO - bikeshed this name?
export CONFIG_POOL=zpool



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



