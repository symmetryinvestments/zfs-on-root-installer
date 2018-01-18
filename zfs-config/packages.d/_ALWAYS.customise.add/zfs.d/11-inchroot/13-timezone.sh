#
# Set the timezone
#

# FIXME - this should be parameterised
CONFIG_TIMEZONE="Asia/Hong_Kong"
echo $CONFIG_TIMEZONE > /etc/timezone
ln -nsf /usr/share/zoneinfo/$CONFIG_TIMEZONE /etc/localtime.dpkg-new && \
    mv -f /etc/localtime.dpkg-new /etc/localtime


