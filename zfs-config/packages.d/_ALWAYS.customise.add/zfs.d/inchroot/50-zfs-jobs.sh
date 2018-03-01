#
# Suggested ZFS maintenance and support setup
#

# Allow unprivileged users to run read-only ZFS commands
cp -a /zfs.d/50-zfs.sudoers /etc/sudoers.d/zfs

# FIXME zfs scrub

