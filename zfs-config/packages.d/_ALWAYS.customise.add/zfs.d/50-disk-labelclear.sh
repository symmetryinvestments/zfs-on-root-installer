#
# In order to avoid booting issues, we should clear any old ZFS installs
# with similar details
#

# If there are any pools already discovered, they could cause issues as well
zpool export -af

for dev in $(blkid -t "LABEL=$CONFIG_POOL" -o device); do
    echo "Found $dev with same label as our zpool - running labelclear"
    zpool labelclear -f "$dev"
done
