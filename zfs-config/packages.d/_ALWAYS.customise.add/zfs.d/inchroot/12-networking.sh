#
# Ensure that the networking starts on bootup
#

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
