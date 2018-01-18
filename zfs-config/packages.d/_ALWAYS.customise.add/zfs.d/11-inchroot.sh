#
# Copy some scripts into the buildroot and setup to execute them in a chroot
#

cp -a /zfs.d/11-inchroot /mnt/zfs.d
cp -a /zfs.install /mnt

mount --rbind /dev  /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys  /mnt/sys

chroot /mnt /zfs.install

# Cannot force remove the mounts, that breaks systemd in the ramdisk
## some mounts may have been added during this process
#umount -v -R -l /mnt


