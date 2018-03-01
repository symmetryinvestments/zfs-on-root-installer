#
# Suggested ZFS maintenance and support setup
#

# TODO
# - these pathnames are hardcoded, it would be nice to use relative paths

# Allow unprivileged users to run read-only ZFS commands
cp -a /zfs.d/50-zfs.sudoers /etc/sudoers.d/zfs

# A job to scrub the storage pool(s)
cp -a /zfs.d/50-zfs.scrub /etc/cron.monthly/zfs.scrub
