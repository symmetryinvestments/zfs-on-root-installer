#
# Install the packages needed to use ZFS
#
#
# Ideally, we could just install zfsutils-linux as part of building the image.
# However - the Debian package depends on building kernel modules, which pulls
# in hudreds of megs of dependancies, which we dont need as we are using the
# Ubuntu kernel that already has the modules built
#
# TODO
# - add support for doing a hacky package install at build time and use that
# 

apt update
apt download zfsutils-linux
dpkg -x zfsutils-linux*.deb /

