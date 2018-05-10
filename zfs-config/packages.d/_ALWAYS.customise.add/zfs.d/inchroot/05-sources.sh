#
# Configure the apt sources list
#

# The sources can be managed with runtime-config-managment after the install
# is completed, but using a well-defined initial set is probably not a bad
# idea.

cat > /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu artful main universe
deb-src http://archive.ubuntu.com/ubuntu artful main universe

deb http://security.ubuntu.com/ubuntu artful-security main universe
deb-src http://security.ubuntu.com/ubuntu artful-security main universe

deb http://archive.ubuntu.com/ubuntu artful-updates main universe
deb-src http://archive.ubuntu.com/ubuntu artful-updates main universe
EOF

# FIXME
# - This hardcodes the ubuntu release version of "artful"
#   We could use the sources list left behind by the debootstrap,
#   but that doesnt have all the lines needed
# - This hardcodes the repo URL
