#
# Save the prefix for the zpool command
#

ZFS_POOL_SCRIPT=/tmp/zfs.zpool.script

cat <<EOF >$ZFS_POOL_SCRIPT
# This command will assemble the ZFS disk array
zpool create -f \\
    -O atime=off \\
    -o ashift=12 \\
    -O canmount=off \\
    -O compression=lz4 \\
    -O normalization=formD \\
    -O mountpoint=/ \\
    -R /mnt \\
    \$CONFIG_POOL \\
EOF

echo "$ZFS_VDEVS" | while read line; do
    echo " $line \\" >>$ZFS_POOL_SCRIPT
done

echo >>$ZFS_POOL_SCRIPT

lsblk -n -d -e 11 -o "NAME,MODEL,SIZE,WWN" | while read line; do
    echo "# $line" >>$ZFS_POOL_SCRIPT
done
