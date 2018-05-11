#
# Perform the initial install
#

# The debootstrap version in the per-installation environment is too old to
# have pre-defined profiles for newer distributions.  This is not an issue
# because all the newer distributions have had no major differences in their
# debootstrap profiles for a number of versions now.  So, we can just create
# a couple of symlinks and carry on.

ln -f -s gutsy /usr/share/debootstrap/scripts/artful
ln -f -s gutsy /usr/share/debootstrap/scripts/bionic

export http_proxy=$CONFIG_PROXY

# TODO
# - should we hardcode the ubuntu archive url?
debootstrap --arch=amd64 "$CONFIG_SUITE" /mnt http://archive.ubuntu.com/ubuntu

