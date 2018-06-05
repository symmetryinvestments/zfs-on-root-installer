#
# Copy authorized keys from the ramdisk environment into the target image
#

SRC=~root/authorized_keys
DST=/mnt/root/authorized_keys

# TODO:
# - If the installer is run via ssh, copy any keys from the agent
#if [ -n "$SSH_AUTH_SOCK" ]; then
#    ssh-add -L >$SRC/agent.tmp
#    # This needs some thought, currently we assume the filename is the name
#    # of the user account to create
#fi

# Copy all the keys known in the installer (mostly because they are hardcoded)
if [ -d "$SRC" ]; then
    cp -a "$SRC" "$DST"
fi

