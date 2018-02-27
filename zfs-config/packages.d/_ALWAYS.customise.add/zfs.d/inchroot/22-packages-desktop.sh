#
# Install the desktop packages
#

# check if this is to be an interactive system
if [ -n "$CONFIG_DESKTOP" ]; then
    # grumble... the ubuntu-desktop installs something else that in turn
    # restarts NetworkManager, however network manager is not running, which
    # causes the install process to fail ..
    apt install -y network-manager
    systemctl start NetworkManager

    PACKAGES+=" $CONFIG_DESKTOP"
fi
