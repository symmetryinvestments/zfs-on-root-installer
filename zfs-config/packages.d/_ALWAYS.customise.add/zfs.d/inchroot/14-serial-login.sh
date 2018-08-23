#
# Provide a serial login
#

systemctl enable serial-getty@ttyS1.service

#
# TODO
# - parse the ACPI tables that define serial consoles and try to enable the
#   correct one ...
