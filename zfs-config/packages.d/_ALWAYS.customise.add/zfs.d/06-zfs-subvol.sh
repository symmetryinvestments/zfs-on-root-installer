#
# Create the subvolumes
#

zfs create -o canmount=off -o mountpoint=none $ROOT_POOL/ROOT
zfs create -o canmount=noauto -o mountpoint=/ $ROOT_POOL/ROOT/ubuntu
zfs mount $ROOT_POOL/ROOT/ubuntu
zfs create -o setuid=off $ROOT_POOL/home
zfs create -o mountpoint=/root $ROOT_POOL/home/root
zfs create -o canmount=off -o setuid=off -o exec=off $ROOT_POOL/var
zfs create -o com.sun:auto-snapshot=false $ROOT_POOL/var/cache
zfs create $ROOT_POOL/var/log
zfs create $ROOT_POOL/var/spool
zfs create -o com.sun:auto-snapshot=false -o exec=on $ROOT_POOL/var/tmp
chmod 1777 /mnt/var/tmp

zfs set devices=off $ROOT_POOL

