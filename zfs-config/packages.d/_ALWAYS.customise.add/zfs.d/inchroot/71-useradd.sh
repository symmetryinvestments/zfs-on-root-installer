#
# Create a regular user
#

# TODO
# - Remove the hamish user - it is a hack
useradd -m hamish -s /bin/bash -G sudo
echo -e hamish:hamish | chpasswd

# - ssh authorised keys

if [ -n "$CONFIG_USER" ]; then
    useradd -m "$CONFIG_USER" -s /bin/bash -c "$CONFIG_USER_FN"
    echo -e "$CONFIG_USER:$CONFIG_USER_PW" | chpasswd
fi
