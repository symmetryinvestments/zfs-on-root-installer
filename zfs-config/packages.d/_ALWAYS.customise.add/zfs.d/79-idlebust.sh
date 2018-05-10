# The travis CI assumes that any job that has no output for 10 minutes is
# frozen.  During our install, there are some places where there is no output
# for an extended period.  So we generate some bogus output here.  Doing it
# in this script gives us more control than doing it in the travis.yml
#
# Places known to take too long without output are:
# - during "Unpacking the base system"
# - during "update-initramfs"

echo "starting idle buster"
while sleep 9m; do echo -e "\n=== IDLE BUSTER $SECONDS seconds ===\n"; done &

