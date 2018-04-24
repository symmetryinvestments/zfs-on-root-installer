#
# Build an installer image to boot a bare-metal server and install a ZFS root
# disk
#

all: bootable-images

SUBDIRS := debian kernel

CLEAN_FILES := nothing

CONFIGDIRS := .
CONFIGDIRS += $(abspath zfs-config)
export CONFIGDIRS

# The minimal install system is built as this arch, not the installed server
CONFIG_DEBIAN_ARCH := i386
export CONFIG_DEBIAN_ARCH

CONFIG_DEBIAN_VER := stretch

ISODIR := iso
DISK_IMAGE := $(ISODIR)/boot.img
ISO_IMAGE := boot.iso

.PHONY: bootable-images
bootable-images: $(DISK_IMAGE) $(ISO_IMAGE)

build-depends: debian/Makefile
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	sudo apt -y install ovmf xorriso expect mtools

# Calculate the basename of the debian build file
DEBIAN_BASENAME = debian.$(CONFIG_DEBIAN_VER).$(CONFIG_DEBIAN_ARCH)
DEBIAN = debian/build/$(DEBIAN_BASENAME)

# Rules to go and make the debian installed root
# Note: this has no dependancy checking, and will simply use what ever
# file is there
.PHONY: debian
debian: debian/Makefile
	$(MAKE) -C debian build/$(DEBIAN_BASENAME).cpio

$(DEBIAN).cpio: debian

# Ensure that the submodule is actually present
debian/Makefile:
	git submodule update --init --remote

kernel/ubuntu.amd64.kernel kernel/ubuntu.amd64.modules.cpio:
	$(MAKE) -C kernel all

combined.initrd: $(DEBIAN).cpio kernel/ubuntu.amd64.modules.cpio
	cat $^ >$@

# Create a file with the size of the needed disk image in it
size.txt: combined.initrd kernel/ubuntu.amd64.kernel
	echo $$(($$(stat -c %s combined.initrd)/1048576 +$$(stat -c %s kernel/ubuntu.amd64.kernel)/1048576 +2)) >$@

$(DISK_IMAGE): size.txt startup.nsh combined.initrd kernel/ubuntu.amd64.kernel
	mkdir -p $(dir $@)
	truncate --size=$$(cat size.txt)M $@.tmp
	mformat -i $@.tmp -v EFS -N 2 -t $$(cat size.txt) -h 64 -s 32 ::
	mmd -i $@.tmp ::efi
	mmd -i $@.tmp ::efi/boot
	mcopy -i $@.tmp kernel/ubuntu.amd64.kernel ::linux.efi
	mcopy -i $@.tmp combined.initrd ::initrd
	mcopy -i $@.tmp startup.nsh ::
	mv $@.tmp $@

$(ISO_IMAGE): $(DISK_IMAGE)
	xorrisofs \
	    -o $@ \
	    --efi-boot $(notdir $(DISK_IMAGE)) \
	    $(ISODIR)

persistent.storage:
	truncate $@ --size=10G
REALLYCLEAN_FILES += persistent.storage

SHELL_SCRIPTS := \
	zfs-config/packages.d/_ALWAYS.customise.add/usr/local/sbin/statuspage \
	zfs-config/packages.d/_ALWAYS.customise.add/zfs.install \
	zfs-config/packages.d/_ALWAYS.customise.add/zfs.d/*.sh \
	zfs-config/packages.d/_ALWAYS.customise.add/zfs.d/inchroot/*.sh \

# Run a shell linter
shellcheck:
	shellcheck --shell bash $(SHELL_SCRIPTS)

# added just for travisCI
CONFIG_DISABLE_KVM ?= no
ifeq ($(CONFIG_DISABLE_KVM),yes)
    QEMU_KVM=
else
    QEMU_KVM=-enable-kvm
endif

QEMU_CMD_NET := -netdev type=user,id=e0 -device virtio-net-pci,netdev=e0
QEMU_CMD_EFI := -bios /usr/share/qemu/OVMF.fd
QEMU_CMD_CDROM := -cdrom $(ISO_IMAGE)

QEMU_CMD := qemu-system-x86_64 $(QEMU_KVM) \
    -m 1500

# Just build the initramfs and boot it directly
test_quick: combined.initrd kernel/ubuntu.amd64.kernel
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    -append console=ttyS0 \
	    -kernel kernel/ubuntu.amd64.kernel \
	    -initrd combined.initrd \
	    -nographic

# Test the EFI boot - with the 'normal' image wrapped in a ISO
test_efi: $(ISO_IMAGE)
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    $(QEMU_CMD_EFI) \
	    $(QEMU_CMD_CDROM) \
	    -display none \
	    -serial null -serial stdio

# Test EFI booting, with an actual graphics console visible
test_efigui: $(ISO_IMAGE)
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    $(QEMU_CMD_EFI) \
	    $(QEMU_CMD_CDROM) \
	    -serial vc -serial stdio

# Test the EFI boot - with the 'simplified' image - not wrapped
test_efihd_persist: $(DISK_IMAGE) persistent.storage
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    $(QEMU_CMD_EFI) \
	    -display none \
	    -serial null -serial stdio \
	    -drive if=virtio,format=raw,file=persistent.storage \
	    -drive if=virtio,format=raw,id=boot,file=$(DISK_IMAGE)

test_efi_persist: $(ISO_IMAGE) persistent.storage
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    $(QEMU_CMD_EFI) \
	    $(QEMU_CMD_CDROM) \
	    -display none \
	    -serial null -serial stdio \
	    -drive if=virtio,format=raw,file=persistent.storage

test_efigui_persist: $(ISO_IMAGE) persistent.storage
	$(QEMU_CMD) \
	    $(QEMU_CMD_NET) \
	    $(QEMU_CMD_EFI) \
	    $(QEMU_CMD_CDROM) \
	    -serial vc -serial stdio \
	    -drive if=virtio,format=raw,file=persistent.storage

# TODO - define the ROOT password only in one place, instead of here and in the
# debian/ submodule
INSTALLER_ROOT_PASS:=root

# Common definitions used for all test targets
TEST_HARNESS := ./debian/scripts/test_harness
TEST_TARGET := test_efihd_persist
TEST_ARGS := config_pass=$(INSTALLER_ROOT_PASS)
TEST_CMD := $(TEST_HARNESS) "make $(TEST_TARGET)" $(TEST_ARGS)

TESTS1 := tests/01boot.expect tests/05login_installer.expect \
    tests/07waitjobs.expect
TESTS2 := $(TESTS1) tests/10install1.expect
TESTS3 := $(TESTS2) tests/10install2.expect

# Run a test script for perform a full system install
.PHONY: test.full
test.full: debian/Makefile
	rm -f persistent.storage
	$(TEST_CMD) tests/*.expect

# Partial tests that complete faster
.PHONY: test.partial1 test.partial2 test.partial3
test.partial1: debian/Makefile; $(TEST_CMD) $(TESTS1)
test.partial2: debian/Makefile; $(TEST_CMD) $(TESTS2)
test.partial3: debian/Makefile; $(TEST_CMD) $(TESTS3)

.PHONY: test
test: shellcheck test.full

clean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	rm -f $(CLEAN_FILES)

reallyclean:
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true
	rm -f $(REALLYCLEAN_FILES)
