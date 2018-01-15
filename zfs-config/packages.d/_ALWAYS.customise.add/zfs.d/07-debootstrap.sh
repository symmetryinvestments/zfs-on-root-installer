#
# Perform the initial install
#

# FIXME - release signature keyring file
debootstrap --arch=amd64 artful /mnt http://archive.ubuntu.com/ubuntu

