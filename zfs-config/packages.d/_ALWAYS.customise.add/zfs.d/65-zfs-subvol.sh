#
# Create the subvolumes
#

zfs create -o mountpoint=none -o canmount=off        "$CONFIG_POOL/ROOT"
zfs create -o mountpoint=/                           "$CONFIG_POOL/ROOT/ubuntu"
zfs create -o mountpoint=/home -o setuid=off         "$CONFIG_POOL/home"
zfs create -o mountpoint=/root                       "$CONFIG_POOL/home/root"
zfs create -o mountpoint=/var -o canmount=off -o setuid=off -o exec=off "$CONFIG_POOL/var"
zfs create -o mountpoint=/var/cache -o com.sun:auto-snapshot=false "$CONFIG_POOL/var/cache"
zfs create -o mountpoint=/var/log                    "$CONFIG_POOL/var/log"
zfs create -o mountpoint=/var/spool                  "$CONFIG_POOL/var/spool"
zfs create -o mountpoint=/var/stank                  "$CONFIG_POOL/var/stank" # TODO - is this just a spelling mistake?
zfs create -o mountpoint=/var/tmp -o com.sun:auto-snapshot=false -o exec=on "$CONFIG_POOL/var/tmp"
zfs create -o mountpoint=/srv                        "$CONFIG_POOL/srv"
zfs create -o mountpoint=/var/mail                   "$CONFIG_POOL/var/mail"
zfs create -o mountpoint=/var/lib/nfs -o com.sun:auto-snapshot=false "$CONFIG_POOL/var/nfs"
chmod 1777 /mnt/var/tmp

# When running on linux/ubuntu/grub, it appears that the environment does not
# require the bootfs var to be set.  The documentation also says that setting
# this also causes ZFS to impose some restrictions on the size+shape of the
# boot filesystem, which we do not want
#
# zpool set bootfs=$CONFIG_POOL/ROOT/ubuntu $CONFIG_POOL

zfs set devices=off "$CONFIG_POOL"

