#
# Provide a User interface to set/change the disk config
#

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    tempinput=$(mktemp)
    tempfile=$(mktemp)

    # TODO
    # - I would prefer the lsblk output to have sizes in standard SI units
    #   (as opposed to crazy Gibibytes) but the lsblk program does not obey
    #   the blocksize var:
    # export BLOCKSIZE=KB

    bdev_best_name | while read -r dev; do
        desc=$(lsblk -n -d -e 11 -o "SIZE,NAME,MODEL" "$dev")
        state=off
        for i in $ZFS_DISKS; do
            if [ "$i" == "$dev" ]; then
                state=on
            fi
        done
        echo "$dev \"$desc\" $state" >>"$tempinput"
    done

    if ! dialog \
        --backtitle "ZFS Root Installer" \
        --visit-items \
        --checklist \
        "Select the disks to wipe and partition for ZFS and ESP" 20 80 16 \
        --file "$tempinput" \
        2>"$tempfile"; then

        # assume the user wanted to cancel
        exit 1
    fi

    ZFS_DISKS=$(cat "$tempfile")
fi
