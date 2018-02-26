#
# Provide a User interface to set/change some of the config
#


if [ "$CONFIG_UNATTENDED" != "true" ]; then
    # A list of packages to install to turn the system into a desktop
    # environment
    CONFIG_DESKTOP="mate-desktop lightdm"

    tempfile=`tempfile`

    dialog --ok-label "Submit" \
        --backtitle "ZFS Root Installer" \
        --form \
        "Configuration" 20 50 0 \
        "ZFS Zpool Name:"   1 1 "$CONFIG_POOL"      1 18 26 80 \
        "System Locale:"    2 1 "$CONFIG_LOCALE"    2 18 26 80 \
        "System Timezone:"  3 1 "$CONFIG_TIMEZONE"  3 18 26 80 \
        "Desktop Package:"  4 1 "$CONFIG_DESKTOP"   4 18 26 200 \
        2>$tempfile
    if [ "$?" -ne 0 ]; then
        # assume the user wanted to cancel
        exit
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
fi

###
if [ "$CONFIG_UNATTENDED" != "true" ]; then
    dialog --ok-label "Submit" \
        --backtitle "ZFS Root Installer" \
        --visit-items \
        --buildlist \
        "Select disks to zap and partition" 20 50 16 \
        tag item on \
        tag1 item1 off \
        tag2 item2 on \
        tag3 item3 on
fi

