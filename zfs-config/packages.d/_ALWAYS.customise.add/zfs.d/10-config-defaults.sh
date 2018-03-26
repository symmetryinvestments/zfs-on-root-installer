#
# Set the default values for all the configuration
#

# Unless otherwise set, we assume we are running an attended install
if [ -z "$CONFIG_UNATTENDED" ]; then
    export CONFIG_UNATTENDED=false
fi

export CONFIG_POOL=tank
export CONFIG_LOCALE="en_HK.UTF-8"
export CONFIG_TIMEZONE="Asia/Hong_Kong"
export CONFIG_DESKTOP=
export CONFIG_PROXY=http://10.16.185.42:3142
export CONFIG_ROOT_PW=root

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    # A list of packages to install to turn the system into a desktop
    # environment
    CONFIG_DESKTOP="ubuntu-gnome-desktop"
fi

# TODO
# - should not set the proxy here, should try and autodetect it

# local user to create - not expected to be set in the defaults, but eg:
#export CONFIG_USER=username
#export CONFIG_USER_FN="Hamish Coleman"
#export CONFIG_USER_PW=xyzzy

# Things setup by the disk plan:
# disks to zap and partition
#   ZFS_PART_BULKBOOT   - part9 is 550M EFS, part1 is rest
#   ZFS_PART_CACHE      - part1 is ($ram/2 * 5) in size
#   ZFS_PART_SLOG       - part1 is 25G in size (assume 4*10gbit traffic per 5s)
# layout of zfs pool
#   ZFS_VDEVS
