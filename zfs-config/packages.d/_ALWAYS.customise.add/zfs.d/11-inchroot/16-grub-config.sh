#
# Configure some misc grub settings
#

GRUBCFG=/etc/default/grub
sed -i -e 's/GRUB_HIDDEN_TIMEOUT=0/#GRUB_HIDDEN_TIMEOUT=5/g' $GRUBCFG
sed -i -e 's/"quiet splash"/""/g' $GRUBCFG
sed -i -e 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' $GRUBCFG

# FIXME - serial console?
