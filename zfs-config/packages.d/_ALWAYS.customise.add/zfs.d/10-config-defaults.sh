#
# Set the default values for all the configuration
#

# In the future, this should be set by the wrapper script
export CONFIG_UNATTENDED=false


export CONFIG_POOL=tank
export CONFIG_LOCALE="en_HK.UTF-8"
export CONFIG_TIMEZONE="Asia/Hong_Kong"
export CONFIG_DESKTOP=
export CONFIG_PROXY=http://10.16.185.42:3142
export CONFIG_ROOT_PW=root

# TODO
# - should not set the proxy here, should try and autodetect it

# local user to create - not expected to be set in the defaults, but eg:
#export CONFIG_USER=username
#export CONFIG_USER_FN="Hamish Coleman"
#export CONFIG_USER_PW=xyzzy

# Things setup by the disk plan:
# disks to zap and partition
#   ZFS_DISKS
# layout of zfs pool
#   ZFS_VDEVS
