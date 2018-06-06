#
# Install openssh-server
#

# this is separated from the other packages because there seems to be some
# kind of bug with the installation of openssh-server when you are running
# in a nested VM - specifically travisCI, but also tested with libvirt and
# qemu and ubuntu 14.04
#
# By separating it out, it can be turned off for testing in that environment

apt install -y openssh-server

# Additional details:
#
# Example log for a build exhibiting the error:
# https://travis-ci.com/symmetryinvestments/zfs-on-root-installer/builds/75470828
#
# 00:54:54 Creating config file /etc/ssh/sshd_config with new version
# 00:54:58 Creating SSH2 RSA key; this may take some time ...
# 00:54:58 2048 SHA256:tAK/rUUwzWtXS13ICzr7aBDW6NADQ0U5ma0VRUdWHfQ root@ramdisk-566a832f (RSA)
# 00:54:58 Creating SSH2 ECDSA key; this may take some time ...
# 00:54:58 /etc/ssh/ssh_host_ecdsa_key.pub is not a public key file.
# 00:54:59 dpkg: error processing package openssh-server (--configure):
# 00:54:59  installed openssh-server package post-installation script subprocess returned error exit status 255
#
# Earlier debugging builds that captured the contents of the ssh config files
# showed no syntax errors or other issues.
#
# The program that outputs the "not a public key file" message is simply
# reading in the generated .pub file.
