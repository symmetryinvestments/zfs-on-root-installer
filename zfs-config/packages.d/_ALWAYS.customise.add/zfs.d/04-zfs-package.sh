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

# Download the zfs utils if they are not installed in the image already
if [ ! -x "/sbin/zpool" ]; then
    apt update
    apt download zfsutils-linux
    dpkg -x zfsutils-linux*.deb /
    # rm -f zfsutils-linux*.deb

    # we normally dont need to install anything else in the ramdisk, so
    # cleanup the space used
    rmdir /var/lib/apt/auxfiles
    apt clean
    rm -rf /var/lib/apt/list/*
fi
