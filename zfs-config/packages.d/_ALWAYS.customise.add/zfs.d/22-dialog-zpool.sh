#
# Provide a User interface to set/change the disk config
#

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    tempfile=$(mktemp)

    if ! dialog \
        --backtitle "ZFS Root Installer" \
        --title "ZFS Array layout (args for zpool create)" \
        --editbox \
        "$ZFS_POOL_SCRIPT" 24 80 \
        2>"$tempfile"; then

        # assume the user wanted to cancel
        exit 1
    fi

    # replace script with edited version
    mv "$tempfile" "$ZFS_POOL_SCRIPT"
fi
