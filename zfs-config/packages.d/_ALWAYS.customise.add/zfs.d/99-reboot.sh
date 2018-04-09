#
# All done, reboot
#

echo
echo Install is complete,
echo
if [ "$CONFIG_UNATTENDED" != "true" ]; then
    read -r -p "hit enter to reboot"
fi

systemctl reboot


