#
# Create the initial zpool
#

if [ -z "$CONFIG_POOL" ]; then
    export CONFIG_POOL=tank
fi



zpool create -f \
    -O atime=off \
    -o ashift=12 \
    -O canmount=off \
    -O compression=lz4 \
    -O normalization=formD \
    -O mountpoint=/ \
    -R /mnt \
    $CONFIG_POOL \
    $ZFS_VDEVS



