#
# Build an installer image to boot a bare-metal server and install a ZFS root
# disk
#

all:
	@echo not yet
	false

SUBDIRS := debian

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


clean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	rm -f $(CLEAN_FILES)


