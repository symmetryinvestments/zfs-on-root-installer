#
# Set the initial hostname
#

echo "$CONFIG_HOSTNAME" >/etc/hostname
echo "127.0.1.1 $CONFIG_HOSTNAME" >>/etc/hosts

