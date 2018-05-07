#
# An optional script that will stop the installation process after the stage1
# steps are complete
#
# This is enabled by adding the execute permission to this script
#

# TODO
# - save the current environment vars into the new root (so they can be loaded
#   by the 11-config-load.sh during stage2 resume)

zpool export "$CONFIG_POOL" || true

echo
echo Stage 1 completed
echo
if [ "$CONFIG_UNATTENDED" != "true" ]; then
    read -r -p "hit enter to halt"
fi

systemctl poweroff
