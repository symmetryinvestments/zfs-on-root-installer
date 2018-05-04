#
# Ensure that the networking starts on bootup
#

# On many systems, there are multiple network devices, but we dont know which
# devices are connected - so we cannot configure the wait-online service
# to exclude the unused ports.  This causes the unit to fail and systemd thus
# shows the entire system as running in degraded mode.
# Lets avoid that.
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service

# no desktop environments currently read the status from systemd-network
# So, we only configure systemd networkd on server systems
if [ -z "$CONFIG_DESKTOP" ]; then

    apt remove -y nplan

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

    # TODO
    # - Since we expect to run hypervisors, it would be nice to be able to
    #   create a vtap interface to automatically be our connection to the
    #   outside world
    # - Similar argument goes for bond devices
fi

# If we are running a desktop, thus dont have systemd-networkd (see above)
# then we will need to tell NotworkMangler to actually manage devices
if [ -n "$CONFIG_DESKTOP" ]; then

    cat >/etc/netplan/all.yaml <<EOF
network:
    version: 2
    renderer: NetworkManager
EOF

fi
