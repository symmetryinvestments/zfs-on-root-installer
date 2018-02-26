#
# Create a regular user
#

# FIXME
# - dont hardcode this

useradd -m hamish
echo -e hamish:hamish | chpasswd
