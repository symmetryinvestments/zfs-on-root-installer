#
# Create a regular user
#

# TODO
# - dont hardcode this list of users
useradd -m hamish -s /bin/bash -G sudo

# FIXME
# - dont set the password!
echo -e hamish:hamish | chpasswd

# - ssh authorised keys

if [ -n "$CONFIG_USER" ]; then
    useradd -m $CONFIG_USER -s /bin/bash -c "$CONFIG_USER_FN"
    echo -e $CONFIG_USER:$CONFIG_USER_PW | chpasswd
fi
