#
# "Export", or unmount the ZFS filesystem
#

# ensure that the buildroot is unmounted
umount -l /mnt

zpool export $ROOT_POOL


