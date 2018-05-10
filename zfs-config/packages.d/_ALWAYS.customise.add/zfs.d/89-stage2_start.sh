#
# Resume an install for the second stage - everything in the chroot
#

set -e

# Make it clear we are in stage2
script_prefix=stage2

# Make an assumption about (un)attended mode - given that the stage2 is only
# expected to be used when doing test builds, we assume unattended.
: "${CONFIG_UNATTENDED:=true}"

runscripts() {
    for i in "$@"; do
        if [ -x "/zfs.d/$i" ]; then
            echo "Starting script $script_prefix $i:"

            # shellcheck source=/dev/null
            # all to be checked by shellcheck separately
            . "/zfs.d/$i"
        fi
    done
}

# The travis CI assumes that any job that has no output for 10 minutes is
# frozen.  During our install, there are some places where there is no output
# for an extended period - in particular, during "update-initramfs",  so we
# generate some bogus output here.  Doing it in this script gives us more
# control than doing it in the travis.yml
echo "stage2: starting idle buster"
while sleep 9m; do echo -e "\n=== IDLE BUSTER $SECONDS seconds ===\n"; done &

echo "stage2: setting up environment"
runscripts 10-config-defaults.sh 40-zfs-package.sh \
    45-modprobe-efi.sh 45-modprobe-zfs.sh

echo "stage2: importing ZFS"
zpool import -N -R /mnt "$CONFIG_POOL"

# FIXME
# - this has specific ordering to avoid trying to overmount things
echo "stage2: mounting ZFS volumes"
zfs mount "$CONFIG_POOL/ROOT/ubuntu"
zfs mount -a

echo "stage2: resuming install"
runscripts 11-config-load.sh 90-inchroot.sh 95-zfs-export.sh 99-reboot.sh
