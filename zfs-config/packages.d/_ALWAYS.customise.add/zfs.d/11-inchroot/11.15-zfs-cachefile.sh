#
# create a cachefile with our current settings
#
# there is a systemd unit to load the cache on bootup, which fails if the
# file is not there - no other issues have been seen from missing it (but
# no complex disk setups were used either)

zpool set cachefile=/etc/zfs/zpool.cache $CONFIG_POOL
