#
# Create the subvolumes
#

zfs create -o canmount=off -o mountpoint=none $CONFIG_POOL/ROOT
zfs create -o canmount=noauto -o mountpoint=/ $CONFIG_POOL/ROOT/ubuntu
zfs mount $CONFIG_POOL/ROOT/ubuntu
zfs create -o setuid=off $CONFIG_POOL/home
zfs create -o mountpoint=/root $CONFIG_POOL/home/root
zfs create -o canmount=off -o setuid=off -o exec=off $CONFIG_POOL/var
zfs create -o com.sun:auto-snapshot=false $CONFIG_POOL/var/cache
zfs create $CONFIG_POOL/var/log
zfs create $CONFIG_POOL/var/spool
zfs create -o com.sun:auto-snapshot=false -o exec=on $CONFIG_POOL/var/tmp
zfs create $CONFIG_POOL/srv
zfs create $CONFIG_POOL/var/mail
zfs create -o com.sun:auto-snapshot=false -o mountpoint=/var/lib/nfs $CONFIG_POOL/var/nfs
chmod 1777 /mnt/var/tmp

zfs set devices=off $CONFIG_POOL

