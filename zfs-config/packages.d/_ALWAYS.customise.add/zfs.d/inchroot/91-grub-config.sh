#
# Configure some misc grub settings
#

GRUBCFG=/etc/default/grub
sed -i -e 's/GRUB_HIDDEN_TIMEOUT=0/#GRUB_HIDDEN_TIMEOUT=5/g' $GRUBCFG
sed -i -e 's/"quiet splash"/""/g' $GRUBCFG
sed -i -e 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' $GRUBCFG

# Serial console:
# Because this is grub-efi, it uses the EFI console handling functions to draw
# its menu.  Those functions automatically send output to the available serial
# console devices.  So we get serial console for free.
#
# Note, for performance reasons, there is nothing configuring the linux console
# to show on the serial console - if needed, that can be manually enabled
# during a debugging session.
#
# Finally, an earlier script part has setup a serial-getty@ttyS1 to allow
# logins
#
