#
# Ensure that there are no mdadm devices or tasks that could interfere
# with the reformatting and repartitioning 
#

pkill -9 -e mdadm || true

# attempt to stop all mdadm devices
mdadm --stop --scan

if grep ^md /proc/mdstat; then
    echo ERROR: mdadm devices still exist even after trying to stop them
    false
    exit
fi

# disable auto-assembly of any md devices
echo "AUTO -all" >>/etc/mdadm/mdadm.conf
