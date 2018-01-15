#
# Build an installer image to boot a bare-metal server and install a ZFS root
# disk
#

all:
	@echo not yet
	false

SUBDIRS := debian kernel

CLEAN_FILES := nothing

CONFIGDIRS := .
CONFIGDIRS += zfs-config
export CONFIGDIRS

# The minimal install system is built as this arch, not the installed server
CONFIG_DEBIAN_ARCH := i386
export CONFIG_DEBIAN_ARCH

CONFIG_DEBIAN_VER := stretch

build-depends:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	sudo apt install ovmf

# Calculate the basename of the debian build file
DEBIAN_BASENAME = debian.$(CONFIG_DEBIAN_VER).$(CONFIG_DEBIAN_ARCH)
DEBIAN = debian/build/$(DEBIAN_BASENAME)

# Rules to go and make the debian installed root
# Note: this has no dependancy checking, and will simply use what ever
# file is there
$(DEBIAN).cpio: debian/Makefile
	$(MAKE) -C debian build/$(DEBIAN_BASENAME).cpio

# Ensure that the submodule is actually present
debian/Makefile:
	git submodule update --init --remote

kernel/ubuntu.amd64.kernel kernel/ubuntu.amd64.modules.cpio:
	$(MAKE) -C kernel all

combined.initrd: $(DEBIAN).cpio kernel/ubuntu.amd64.modules.cpio
	cat $^ >$@

test_quick: combined.initrd kernel/ubuntu.amd64.kernel
	qemu-system-x86_64 -enable-kvm -append console=ttyS0 \
	    -m 1024 \
	    -kernel kernel/ubuntu.amd64.kernel \
	    -initrd combined.initrd \
	    -netdev type=user,id=e0 -device virtio-net-pci,netdev=e0 \
	    -nographic

clean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	rm -f $(CLEAN_FILES)

reallyclean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
