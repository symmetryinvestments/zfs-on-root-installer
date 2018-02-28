#
# Create the initial zpool
#

if [ -z "$CONFIG_POOL" ]; then
    export CONFIG_POOL=tank
fi

# shellcheck source=/dev/null
# Script is generated in 13-config-zpool.sh
. "$ZFS_POOL_SCRIPT"
