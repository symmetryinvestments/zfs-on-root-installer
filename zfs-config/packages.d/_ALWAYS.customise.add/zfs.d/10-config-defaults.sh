#
# Set the default values for all the configuration
#

# TODO
# - invent a proxy autodetection process and use that in a different file

export CONFIG_UNATTENDED CONFIG_POOL CONFIG_LOCALE CONFIG_TIMEZONE \
    CONFIG_DESKTOP CONFIG_PROXY CONFIG_ROOT_PW CONFIG_SUITE

# Set defaults for config, unless already set in the environment
: "${CONFIG_UNATTENDED:=false}"
: "${CONFIG_POOL:=tank}"
: "${CONFIG_LOCALE:=en_HK.UTF-8}"
: "${CONFIG_TIMEZONE:=Asia/Hong_Kong}"
: "${CONFIG_ROOT_PW:=root}"

# : "${ CONFIG_PROXY:=FIXME}"

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    # The reasoning is that an unattended install is driven by some automation
    # and that automation can come back later and automatically add the right
    # packages for the system - so unattended does not need any desktop package
    # list.
    # Also, people testing the installer will probably be performing attended
    # installs, so provide a default package to install the desktop environment
    # (which is also shown to the user in the config dialog)

    # A list of packages to install to turn the system into a desktop
    # environment
    CONFIG_DESKTOP="ubuntu-gnome-desktop"
fi

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
