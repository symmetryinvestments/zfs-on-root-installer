#
# Install the desktop packages
#

# check if this is to be an interactive system
if [ -n "$CONFIG_DESKTOP" ]; then
    # Ubuntu 17.10 defaults to wayland.  Wayland defaults to suck.  Suck can
    # be removed from all login managers with the following:
    mkdir -p /usr/share/wayland-sessions/hidden
    for i in gnome ubuntu; do
        dpkg-divert --rename \
          --divert /usr/share/wayland-sessions/hidden/${i}.desktop \
          --add /usr/share/wayland-sessions/${i}.desktop
    done
    # TODO
    # - this assumes that only two .desktop type files will ever exist

    # Additionally, to stop gdm3 from using wayland for the login screen:
    sed -i -E -e 's/^#(WaylandEnable=false)/\1/' /etc/gdm3/custom.conf

    # TODO
    # - divert /usr/share/xgreeters/unity-greeter.desktop
fi
