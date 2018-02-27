#
# As the last step inside the target system, take a snapshot
#

zfs snapshot $CONFIG_POOL/ROOT/ubuntu@install
