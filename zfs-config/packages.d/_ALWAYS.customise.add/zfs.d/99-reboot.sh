#
# All done, reboot
#

echo
echo
if [ "$CONFIG_UNATTENDED" != "true" ]; then
    read -r -p "Install is complete, hit enter to reboot"
fi

systemctl reboot


