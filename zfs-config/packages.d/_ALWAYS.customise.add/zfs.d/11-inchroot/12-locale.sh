#
# Set the locale
#

# FIXME - this should be parameterised
CONFIG_LOCALE="en_HK.UTF-8"

locale-gen $CONFIG_LOCALE
echo "LANG=\"$CONFIG_LOCALE\"" > /etc/default/locale

