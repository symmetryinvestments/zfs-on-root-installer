#
# Ensure that the networking starts on bootup
#

mkdir -p /mnt/etc/systemd/system/multi-user.target.wants/

# enable systemd-networkd and systemd-resolved
cp -a /etc/systemd/system/multi-user.target.wants/ /mnt/etc/systemd/system/multi-user.target.wants/

# Add a default config for ethernet devices
cp -a /etc/systemd/network/95-defaulteth.network /mnt/etc/systemd/network/

# Point name services at the systemd-resolved
echo nameserver 127.0.0.53 >/mnt/etc/resolv.conf

