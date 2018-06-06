#
# Install openssh-server
#

# this is separated from the other packages because there seems to be some
# kind of bug with the installation of openssh-server when you are running
# in a nested VM - specifically travisCI, but also tested with libvirt and
# qemu and ubuntu 14.04

apt install -y openssh-server
