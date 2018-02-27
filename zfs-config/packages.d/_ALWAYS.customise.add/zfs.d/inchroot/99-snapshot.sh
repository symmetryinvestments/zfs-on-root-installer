#
# We have reached a good recovery point, snapshot the system
#

zfs snapshot $CONFIG_POOL/ROOT/ubuntu@install

# FIXME
# - we have not setup swap yet
# - we have not setup the root password yet

