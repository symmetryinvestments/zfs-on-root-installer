#
# Configure the locale
#

locale-gen $CONFIG_LOCALE
echo "LANG=\"$CONFIG_LOCALE\"" > /etc/default/locale

