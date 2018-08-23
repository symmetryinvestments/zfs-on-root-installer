#
# Copy the os-release BUILDER_ vars into the built image
#

grep "^BUILDER_" /etc/os-release >>/mnt/etc/os-release
