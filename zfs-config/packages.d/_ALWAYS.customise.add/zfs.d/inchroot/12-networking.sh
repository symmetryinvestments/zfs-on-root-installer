#
# Ensure that the networking starts on bootup
#

# On many systems, there are multiple network devices, but we dont know which
# devices are connected - so we cannot configure the wait-online service
# to exclude the unused ports.  This causes the unit to fail and systemd thus
# shows the entire system as running in degraded mode.
# Lets avoid that.
systemctl mask systemd-networkd-wait-online.service

# TODO
# - no desktop environments read status from systemd-network properly
#   so, just use NotworkMangler on desktop installs?

systemctl enable systemd-networkd
systemctl enable systemd-resolved

cat >/etc/systemd/network/95-defaulteth.network <<EOF
# By default, all ethernet ports are clients trying to become our upstream
[Match]
Name=eth* en*

[Network]
DHCP=yes
LLMNR=true
MulticastDNS=true
LLDP=true
EmitLLDP=true
EOF

# Point name services at the systemd-resolved
echo nameserver 127.0.0.53 >/etc/resolv.conf
