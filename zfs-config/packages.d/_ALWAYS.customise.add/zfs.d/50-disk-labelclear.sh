#
# In order to avoid booting issues, we should clear any old ZFS installs
# with similar details
#

for dev in $(blkid -t "LABEL=$CONFIG_POOL" -o device); do
    echo "Found $dev with same label as our zpool - running labelclear"
    zpool labelclear -f "$dev"
done
