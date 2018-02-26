#
# Perform the initial install
#

# This debootstrap version is too old to have artful, but luckily these scripts
# have not changed
ln -f -s gutsy /usr/share/debootstrap/scripts/artful

export http_proxy=$CONFIG_PROXY

# TODO
# - should we hardcode the arch?
# - should we hardcode the ubuntu archive url?
debootstrap --arch=amd64 artful /mnt http://archive.ubuntu.com/ubuntu

