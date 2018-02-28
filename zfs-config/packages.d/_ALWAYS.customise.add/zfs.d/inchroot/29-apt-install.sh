#
# Install any requested packages
#

# shellcheck disable=SC2086
# We actually want to word split this arg
apt install -y $PACKAGES
