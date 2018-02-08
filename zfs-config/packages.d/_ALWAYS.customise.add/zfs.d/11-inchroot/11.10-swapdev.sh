#
# Add a swapdev
#

#zfs create -V 4G -b $(getconf PAGESIZE) \
#    -o compression=zle \
#    -o logbias=throughput \
#    -o sync=always \
#    -o primarycache=metadata \
#    -o secondarycache=none \
#    -o com.sun:auto-snapshot=false \
#    $CONFIG_POOL/swap
#
## FIXME - detect the blockdev name
#mkswap -L swap /dev/zd0
#
## FIXME - the installed system doesnt see the swap dev label
#echo LABEL=swap none swap defaults 0 0 >> /etc/fstab
#swapon -av
#swapoff /dev/zd0

