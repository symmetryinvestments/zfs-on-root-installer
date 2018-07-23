#
# Download a usable ubuntu kernel package and extract the bootable kernel and
# needed kernel modules, ready for embedding in a boot disk
#

CONFIG_KERNEL_ARCH=amd64

CONFIG_KERNEL=ubuntu
# TODO - the kernel version number needs manual changing more often than desired
CONFIG_KERNEL_PKG=linux-image-4.13.0-46-generic_4.13.0-46.51_amd64.deb
CONFIG_KERNEL_VERSION=4.13.0-46-generic

KERNEL_POOL=http://archive.ubuntu.com/ubuntu/pool/main/l/linux
KERNEL_PKG=ubuntu.$(CONFIG_KERNEL_PKG)
KERNEL_PKG_DIR=$(KERNEL_PKG).dir

TARGET_KERNEL=$(CONFIG_KERNEL).$(CONFIG_KERNEL_ARCH).kernel
TARGET_MODULES=$(CONFIG_KERNEL).$(CONFIG_KERNEL_ARCH).modules.cpio

all: $(TARGET_KERNEL) $(TARGET_MODULES)

build-depends:
	true

$(KERNEL_PKG):
	wget -O $@ $(KERNEL_POOL)/$(CONFIG_KERNEL_PKG)
	touch $@
REAL_CLEAN += $(KERNEL_PKG)

$(KERNEL_PKG_DIR): $(KERNEL_PKG)
	mkdir -p $@
	dpkg -x $< $@
	touch $@
CLEAN += $(KERNEL_PKG_DIR)

# FIXME - this is fragile
$(TARGET_KERNEL): $(KERNEL_PKG_DIR)
	cp $</boot/vmlinuz-$(CONFIG_KERNEL_VERSION) $@
	touch $@
CLEAN += $(TARGET_KERNEL)

$(TARGET_MODULES): $(KERNEL_PKG_DIR)
	/sbin/depmod -b $< $(CONFIG_KERNEL_VERSION)
	( \
	    cd $<; \
	    find lib -print0 | cpio -0 -H newc -R 0:0 -o \
	) >$@
CLEAN += $(TARGET_MODULES)

clean:
	rm -rf $(CLEAN)

reallyclean:
	rm -rf $(REAL_CLEAN)
