#
# Install the desktop packages
#

# TODO
# - this should be done in the network config section
apt remove -y nplan

# check if this is to be an interactive system
if [ -n "$CONFIG_DESKTOP" ]; then
    # grumble... the ubuntu-desktop installs something else that in turn
    # restarts NetworkManager, however network manager is not running, which
    # causes the install process to fail ..
    apt install -y network-manager
    systemctl start NetworkManager

    PACKAGES+=" $CONFIG_DESKTOP"
fi

