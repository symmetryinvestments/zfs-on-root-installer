#
# Provide a User interface to set/change the disk config
#

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    tempinput=`tempfile`
    tempfile=`tempfile`

    lsblk -n -d -e 11 -o "NAME,MODEL,SIZE,WWN" | while read tag desc; do
        state=off
        for i in $ZFS_DISKS; do
            if [ $(basename $i) == "$tag" ]; then
                state=on
            fi
        done
        echo $tag \"$desc\" $state >>$tempinput
    done

    dialog \
        --backtitle "ZFS Root Installer" \
        --visit-items \
        --checklist \
        "Select the disks to wipe and partition for ZFS and ESP" 20 80 16 \
        --file $tempinput \
        2>$tempfile

    if [ "$?" -ne 0 ]; then
        # assume the user wanted to cancel
        exit 1
    fi

    ZFS_DISKS=
    for i in `cat $tempfile`; do
        ZFS_DISKS+="/dev/$i "
    done
fi
