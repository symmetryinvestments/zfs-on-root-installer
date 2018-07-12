#
# Provide a User interface to set/change the disk config
#

# Given a list of "state=on" disks, create a dialog checklist file with a list
# of all disks.  Output the name of a tempfile with this list
disk_checklist() {
    local used_list="$1"
    tempinput=$(mktemp)

    # TODO
    # - I would prefer the lsblk output to have sizes in standard SI units
    #   (as opposed to crazy Gibibytes) but the lsblk program does not obey
    #   the blocksize var:
    # export BLOCKSIZE=KB

    disk_all | while read -r dev; do
        devpath=$(disk_get "$dev" dev)
        desc=$(lsblk -n -d -e 11 -o "SIZE,NAME,MODEL" "$devpath")
        state=off
        for i in $used_list; do
            if [ "$i" == "$dev" ]; then
                state=on
            fi
        done
        echo "$dev \"$desc\" $state" >>"$tempinput"
    done
    echo "$tempinput" 
}

# Show a dialog of disks
dialog_checklist() {
    local inputfile="$1"
    local outputfile="$2"
    local desc="$3"

    if ! dialog \
        --backtitle "ZFS Root Installer" \
        --visit-items \
        --checklist \
        "$desc" 20 80 16 \
        --file "$inputfile" \
        2>"$outputfile"; then

        # assume the user wanted to cancel
        exit 1
    fi
}

dialog_msg() {
    if ! dialog \
        --backtitle "ZFS Root Installer" \
        --visit-items \
        --msgbox \
        "$*" 15 70; then

        # assume the user wanted to cancel
        exit 1
    fi
}

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    tempinput=$(disk_checklist "$ZFS_PART_BULKBOOT")

    if [ ! -s "$tempinput" ]; then
        dialog_msg "No disks found, cannot continue"
        exit 1
    fi

    tempoutput=$(mktemp)
    dialog_checklist "$tempinput" "$tempoutput" "ZFS data and ESP boot: Marked disks will be wiped and partitioned"
    ZFS_PART_BULKBOOT=$(cat "$tempoutput")

    tempinput=$(disk_checklist "$ZFS_PART_CACHE")
    tempoutput=$(mktemp)
    dialog_checklist "$tempinput" "$tempoutput" "ZFS Cache: Marked disks will be wiped and partitioned"
    ZFS_PART_CACHE=$(cat "$tempoutput")

    tempinput=$(disk_checklist "$ZFS_PART_SLOG")
    tempoutput=$(mktemp)
    dialog_checklist "$tempinput" "$tempoutput" "ZFS SLOG: Marked disks will be wiped and partitioned"
    ZFS_PART_SLOG=$(cat "$tempoutput")
fi
