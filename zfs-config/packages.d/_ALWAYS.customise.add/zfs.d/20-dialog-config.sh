#
# Provide a User interface to set/change some of the config
#

# TODO
# - add CONFIG_SUITE as a menu option?

dialog_ask() {
    local tempfile="$1"

    w_desc=23

    if ! dialog \
        --backtitle "ZFS Root Installer" \
        --insecure \
        --mixedform \
        "Configuration" 18 55 0 \
        " 1 Desktop Package(s):" 1 1 "$CONFIG_DESKTOP"   1 $w_desc 26 200 0 \
        " 2 Root Passwd:"        2 1 "$CONFIG_ROOT_PW"   2 $w_desc 26 16 1 \
        " 3 User Login:"         3 1 "$CONFIG_USER"      3 $w_desc 26 16 0 \
        " 4 User Passwd:"        4 1 "$CONFIG_USER_PW"   4 $w_desc 26 16 1 \
        " 5 User Full Name:"     5 1 "$CONFIG_USER_FN"   5 $w_desc 26 16 0 \
        " 6 System Locale:"      6 1 "$CONFIG_LOCALE"    6 $w_desc 26 80 0 \
        " 7 System Timezone:"    7 1 "$CONFIG_TIMEZONE"  7 $w_desc 26 80 0 \
        " 8 HTTP Proxy:"         8 1 "$CONFIG_PROXY"     8 $w_desc 26 200 0 \
        " 9 ZFS Zpool Name:"     9 1 "$CONFIG_POOL"      9 $w_desc 26 80 0 \
        "10 Hostname:"          10 1 "$CONFIG_HOSTNAME" 10 $w_desc 26 20 0 \
        2>"$tempfile"; then

        # assume the user wanted to cancel
        exit 1
    fi

    # awkwardly read results from the temp file
    get_line() {
        local NR="$1"
        sed -n "${NR}p" "$tempfile"
    }

    CONFIG_DESKTOP=$(get_line 1)
    CONFIG_ROOT_PW=$(get_line 2)
    CONFIG_USER=$(get_line 3)
    CONFIG_USER_PW=$(get_line 4)
    CONFIG_USER_FN=$(get_line 5)
    CONFIG_LOCALE=$(get_line 6)
    CONFIG_TIMEZONE=$(get_line 7)
    CONFIG_PROXY=$(get_line 8)
    CONFIG_POOL=$(get_line 9)
    CONFIG_HOSTNAME=$(get_line 10)
}

dialog_show() {
    local tempfile="$1"

    # FIXME - obscure the passwords!

    show=$(cat -n "$tempfile")
    dialog \
        --clear \
        --backtitle "ZFS Root Installer" \
        --no-collapse --cr-wrap \
        --yes-label "Keep" \
        --no-label "Edit" \
        --yesno "Selected Configuration:\n\
$show" 18 55
}

if [ "$CONFIG_UNATTENDED" != "true" ]; then
    tempfile=$(mktemp)

    set +e
    S=1
    while [ "$S" = "1" ]; do
        dialog_ask "$tempfile"
        dialog_show "$tempfile"
        S="$?"
    done
    set -e
fi
