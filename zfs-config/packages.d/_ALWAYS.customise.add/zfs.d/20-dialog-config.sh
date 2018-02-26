#
# Provide a User interface to set/change some of the config
#


if [ "$CONFIG_UNATTENDED" != "true" ]; then
    # A list of packages to install to turn the system into a desktop
    # environment
    CONFIG_DESKTOP="ubuntu-gnome-desktop"

    tempfile=`tempfile`

    dialog \
        --backtitle "ZFS Root Installer" \
        --insecure \
        --mixedform \
        "Configuration" 20 50 0 \
        "ZFS Zpool Name:"   1 1 "$CONFIG_POOL"      1 18 26 80 0 \
        "System Locale:"    2 1 "$CONFIG_LOCALE"    2 18 26 80 0 \
        "System Timezone:"  3 1 "$CONFIG_TIMEZONE"  3 18 26 80 0 \
        "Desktop Package:"  4 1 "$CONFIG_DESKTOP"   4 18 26 200 0 \
        "Root Passwd:"      5 1 "$CONFIG_ROOT_PW"   5 18 26 16 1 \
        "User Login:"       6 1 "$CONFIG_USER"      6 18 26 16 0 \
        "User Passwd:"      7 1 "$CONFIG_USER_PW"   7 18 26 16 1 \
        "User Full Name:"   8 1 "$CONFIG_USER_FN"   8 18 26 16 0 \
        2>$tempfile
    if [ "$?" -ne 0 ]; then
        # assume the user wanted to cancel
        exit 1
    fi

    # awkwardly read results from the temp file
    get_line() {
        local NR="$1"
        sed -n "${NR}p" "$tempfile"
    }

    CONFIG_POOL=`get_line 1`
    CONFIG_LOCAL=`get_line 2`
    CONFIG_TIMEZONE=`get_line 3`
    CONFIG_DESKTOP=`get_line 4`
    CONFIG_ROOT_PW=`get_line 5`
    CONFIG_USER=`get_line 6`
    CONFIG_USER_PW=`get_line 7`
    CONFIG_USER_FN=`get_line 8`
fi
