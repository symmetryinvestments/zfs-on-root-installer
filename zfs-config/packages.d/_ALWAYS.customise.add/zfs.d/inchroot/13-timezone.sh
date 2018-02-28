#
# Set the timezone
#

echo "$CONFIG_TIMEZONE" > /etc/timezone
ln -nsf "/usr/share/zoneinfo/$CONFIG_TIMEZONE" /etc/localtime.dpkg-new && \
    mv -f /etc/localtime.dpkg-new /etc/localtime


