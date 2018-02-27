A Bare Metal Installer for ZFS on Root
======================================

This repository is intended to produce a bootable UEFI image that allows
installing a full bare system with ZFS disks.

It uses an Ubuntu kernel and a minimal ramdisk builder to host the scripts
used to perform the actual install.

Using the installer image
=========================


1) build the image (see the below section on building)
2) Boot the image (using one of the boot options below)
3) Login to the installer environment (using an option from How to Login below)
4) Install

Install
-------

The ZFS installer script is started by running /zfs.install

It will detect your storage devices and suggest a ZFS layout

Either accept the suggestions or enter your own

Once the install is complete, you will be prompted to reboot



How to Login
============

Network
-------

Serial Console
--------------

Local VGA Screen
----------------


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
boot image to the usb stick.

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
