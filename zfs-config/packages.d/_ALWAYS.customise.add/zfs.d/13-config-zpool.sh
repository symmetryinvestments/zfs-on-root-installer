#
# Save the prefix for the zpool command
#

ZFS_POOL_SCRIPT=/tmp/zfs.zpool.script

cat <<EOF >"$ZFS_POOL_SCRIPT"
# The command to use to assemble the ZFS filesystem.  For review and editing
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

echo "$ZFS_VDEVS" | while read -r line; do
    echo " $line \\" >>"$ZFS_POOL_SCRIPT"
done

echo >>"$ZFS_POOL_SCRIPT"

lsblk -n -d -e 11 -o "NAME,MODEL,SIZE,WWN" | while read -r line; do
    echo "# $line" >>"$ZFS_POOL_SCRIPT"
done
