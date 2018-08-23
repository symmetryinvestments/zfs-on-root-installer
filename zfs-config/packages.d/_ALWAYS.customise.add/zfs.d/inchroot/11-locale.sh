#
# Configure the locale
#

# TODO - perhaps use validlocale(8)
if ! locale-gen "$CONFIG_LOCALE"; then
    # The user specified locale doesnt validate, use a hardcoded fallback.
    echo "WARNING: The locale $CONFIG_LOCALE is invalid"

    # The locale can easily be set once the system is installed..
    CONFIG_LOCALE=en_US.UTF-8
    echo "INFO: Using $CONFIG_LOCALE as a fallback locale"

    locale-gen "$CONFIG_LOCALE"
fi

echo "LANG=\"$CONFIG_LOCALE\"" > /etc/default/locale

