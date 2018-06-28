[![Build Status](https://travis-ci.com/symmetryinvestments/zfs-on-root-installer.svg?branch=master)](https://travis-ci.com/symmetryinvestments/zfs-on-root-installer)

A Bare Metal Installer for ZFS on Root
======================================

This repository is intended to produce a bootable UEFI image that allows
installing a full bare system with ZFS disks.  Be aware that it is not
intended for building dual-boot systems.  While you are given the ability
to choose which disks are used, the EFI boot system will wipe other OS
entries.

It uses an Ubuntu kernel and a minimal ramdisk builder to host the scripts
used to perform the actual install.

Using the installer image
=========================

Quick start:
1) Download the installer image:
   - use a released iso image file from github
   - Alternatively, build the image (see the below section on building)
1) Boot the image (using one of the boot options below)
1) Install

Download
--------

There are two different installer image files created:
- ISO file
- img file

In most circumstances, the ISO image is the one you should be using.  If your
EFI BIOS is particularly old, you may find that the img file works better (if
you do find this, please create a ticket letting us know as much details as
possible - ideally, we could improve the ISO image to work)

These installer image files can be downloaded from the github
[release](https://github.com/symmetryinvestments/zfs-on-root-installer/releases)
page - Use the most recent release for your download.

Once your image file is downloaded, the simplest way to use it is to put the
image onto a USB stick, with a tool like `dd` or [Etcher](https://etcher.io)

For `dd`:
- First, determine what disk to write to:

  `lsblk -d -o NAME,SIZE,LABEL`

  (carefully select the correct disk device)
- Then write the image to the disk:

  `echo "Verify and run: sudo dd if=boot.iso of=$DISK"`

Boot
----

The installer image needs the EFIShell to work.  You will need to set your
computer to boot using EFI and may need to manually interrupt the boot sequence
and tell it to start the EFIshell (systems that have an existing operating
system installed on the hard drive will probably need this manual step)

Once the EFIShell is running it will look for a "startup.nsh" scripts on all
the attached disks - the installer image has one of these scripts, but if your
system has a second disk with such a script, it may not run the correct one.

If you find that the EFIShell is running the wrong script, you can interrupt
the EFIShell by pressing "ESC" when it prompts you and then manually start
the installer by typing "install" at the "Shell>" prompt.

Install
-------

Once booted, the VGA screen on the computer show a status page provided by the
`htop` tool.  The ZFS installation can be started simply by using the *F10* key to
exit the status page.

At the start of the installation, some basic questions will asked (See below for
a complete list with explanations) - the default values are mostly all fine and
will result in a system installed with a gnome desktop environment.

The default root password is `root` and should be changed.  You should also fill
in the User login, password and Full Name.

The installer will then detect your storage devices and suggest a ZFS layout.
The suggested layout will be shown to you in two phases:
1) A series of tick boxes allowing you to check and confirm which disks will be
   partitioned or formatted during the installation
2) The command line to be used to create the ZFS filesystem will be shown for
   editing - allowing advanced users to make additional changes (or just correct
   mistakes in the automated layout detection)

Once the install is complete, you will be prompted to reboot

Note that the installer can also be run from the command line, and that there
is an unattended mode which asks no questions - to assist with automation.

Installation Options Reference
------------------------------

The installer has a number of options available to tune the installed system.

Env Name | Config prompt | Default
---------|---------------|--------
CONFIG_DESKTOP | Desktop Package(s) | ubuntu-gnome-desktop
CONFIG_ROOT_PW | Root Passwd | root
CONFIG_USER | User Login |
CONFIG_USER_PW | User Passwd |
CONFIG_USER_FN | User Full Name |
CONFIG_LOCALE | System Locale | en_HK.UTF-8
CONFIG_TIMEZONE | System Timezone | Asia/Hong_Kong
CONFIG_PROXY | HTTP Proxy |
CONFIG_POOL | ZFS Zpool Name | tank

Diagnosing issues
=================

Error log
---------

Lock file
---------

Ways to Login
=============

Unless you have built your own image, the default root password used by the
installer is `root`

Network
-------

The installer image is running an ssh server.  If you built your own image,
there is an easy process to add ssh authorized keys to the installer.

For simple network discovery, the installer image is also running a mactelnet
server.  If you are on the same network segment as a booted installer, you can
quickly discover the IP address it has used with the mactelnet-client software:
`mactelnet -l` will wait for broadcasts and show the systems detected.  (If
you build your own image, you could add a mactelnetd.users file to allow logins
via this service, but by default it is simply for network discovery)

Serial Console
--------------

A serial console is started on ttyS1, it is running at 115200 bits per second
and is expected to be used when installing server equipment (Configure your IPMI
Serial-over-LAN and connect remotely to this console)

Local VGA Screen
----------------

In addition to the default htop status screen, there is a login prompt on the
virtual console 2 - this can be reached with Ctrl-Alt-F2, and the htop status
screen returned to with Ctrl-Alt-F1

Ways to Boot
============

Booting with a IPMI virtual media
---------------------------------

If you are booting using a BMC and wish to use the virtual media to boot from
then you will most probably need the CDROM ISO image.

Attach the boot.iso file using the virtial media controls

Booting with a USB Stick
------------------------

When booting off a USB Stick, some EFI versions do not support booting from
the stick as if it was a cdrom, so the most compatible method is to write the
boot image to the usb stick.  But that means you need to keep track of twice
as many image files - so ideally, all the EFI versions would work the same..

Use dd (or similar) to write iso/boot.img to your USB Stick.

Some notes on UEFI
------------------

The install image is a EFI bootable disk, and this may require you
to change your firmware boot order to select the installer.  The boot
image has a startup.nsh file that tells the EFI Shell the file to load
and the parameters to use in order to boot (This is the place where the
serial console is specified)

Booting with PXEboot
--------------------

There are two files built for use with pxebooting.

kernel/ubuntu.amd64.kernel      - This is the bootable linux kernel
combined.initrd                 - This is the initrd containing the installer

Using pxelinux, the following stanza could be added to your pxelinux.cfg:

    label baremetalzfs
        linux kernel/ubuntu.amd64.kernel
        append initrd=combined.initrd console=ttyS1,115200
        menu label Bare metal Installer with ZFS on root


Building the image
==================

Before building the image for the first time, ensure that all required
software is installed:

    make build-depends

Then build the main installer images:

    make boot.iso

The completed boot.iso can be used to boot a system.

Not all the dependancies are correctly managed, so if you need to ensure a
full rebuild is done, a clean can be done before the build:

    make clean

If the cached large downloads are also out of date, they can be removed with
the really clean target:

    make reallyclean


Test targets
============

To allow simpler examination of the system and further development, there are
a number of test targets available:

test_quick          - By directly booting the kernel, avoid loading the EFI
    and thus boot the system faster (broadly similar to a PXE boot)

test_efi            - Boot via EFI - allowing confirmation that the built
    image is a valid EFI boot disk.  This target does not open a graphics
    window and assumes only a serial console is in use.

test_efigui         - Boot via EFI with a graphic console.  This is
    basically the same as "test_efi", except that a window showing the
    VGA screen is opened in addition to the serial console output on
    the terminal.

test_efigui_persist - The same as "test_efigui" with the addition of
    a virtual hard drive.  This can be used to test running the ZFS
    installer scripts to completion and then booting the installed system.
    The virtual hard drive is only created if it is missing, so it will
    persist between test runs (if this is not desired, either delete the
    file manually, or run "make reallyclean".


ISSUES
======
- configure apt proxy settings from install environment to installed environ
- Ctrl-Left keystroke sequence doesnt work on text console (x11 is OK)
