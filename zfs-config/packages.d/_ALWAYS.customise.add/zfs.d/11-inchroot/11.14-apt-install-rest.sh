#
# Install any remaining packages
#

apt remove -y nplan

# check if this is to be an interactive system
if [ -n "$CONFIG_DESKTOP" ]; then
    # grumble... the ubuntu-desktop installs something else that in turn
    # restarts NetworkManager, however network manager is not running, which
    # causes the install process to fail ..
    apt install -y network-manager
    systemctl start NetworkManager

    apt install -y $CONFIG_DESKTOP
fi

# eg:
# aptitude install ubuntu-desktop network-manager-config-connectivity-ubuntu_
