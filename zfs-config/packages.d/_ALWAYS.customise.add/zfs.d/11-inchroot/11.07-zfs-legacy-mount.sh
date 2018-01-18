#
# Some filesystems need to be mounted by the legacy fstab, configure them here
#

zfs set mountpoint=legacy $ROOT_POOL/var/log
zfs set mountpoint=legacy $ROOT_POOL/var/tmp

cat >> /etc/fstab << EOF
$ROOT_POOL/var/log /var/log zfs defaults 0 0
$ROOT_POOL/var/tmp /var/tmp zfs defaults 0 0
EOF

