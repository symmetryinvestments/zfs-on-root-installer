#
# Set the initial hostname
#

sed -i -e 's/^ramdisk/installed/' /mnt/etc/hostname
echo 127.0.1.1 `cat /mnt/etc/hostname` >>/mnt/etc/hosts


