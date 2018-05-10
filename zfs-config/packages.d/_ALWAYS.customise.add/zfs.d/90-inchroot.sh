#
# Copy some scripts into the buildroot and setup to execute them in a chroot
#

cp -a /zfs.d/inchroot /mnt/zfs.d
cp -a /zfs.install /mnt

mount -t devtmpfs none /mnt/dev
mount -t devpts none /mnt/dev/pts
mount -t proc none /mnt/proc
mount -t sysfs none /mnt/sys

S=0
script_prefix=inchroot chroot /mnt /zfs.install || S=$?

if [ "$S" -ne 0 ]; then
    # cause an exit, but only /after/ we have cleaned up
    echo "ERROR: something in the chroot exited with an error ($S)"
    false
fi

# Only clean up if we dont exit in the error message above - that allows
# inspection to be done by the user if needed.
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys

rm -f /mnt/zfs.install
rm -rf /mnt/zfs.d
