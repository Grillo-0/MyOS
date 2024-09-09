CFLAGS := -Wall -Wextra -pedantic -ffreestanding -nostdlib -std=gnu2x -ggdb -O2 -I include -mcmodel=medany
KERNEL := main.elf

ARCH  := riscv64
TARGET := $(ARCH)-unknown-elf

CC := $(TARGET)-gcc
AS := $(TARGET)-as

SUBDIRS := drivers

SRCS := main.c boot.asm misc.c

include $(patsubst %,%/Makefile, $(SUBDIRS))

OBJS := \
	$(patsubst %.c,%.o, $(filter %.c,$(SRCS))) \
	$(patsubst %.asm,%.o, $(filter %.asm,$(SRCS)))
DEPS := $(patsubst %.c,%.d, $(filter %.c,$(SRCS)))

BINUTILS_VER := 2.43.1
GCC_VER := 14.2.0
GDB_VER := 15.1
DEVTOOLS_DIR := devtools

PATH := $(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH)
export PATH

BUILD_DIR := build

.PHONY: all
all: $(KERNEL)

$(KERNEL): $(OBJS) linker.ld
	$(CC) $(CFLAGS) -T linker.ld -lgcc $(OBJS) -o $@

%.d: %.c
	$(CC) $(CFLAGS) -MM -MG -MT '$(patsubst %.d,%.o, $@) $@' $< -o $@
-include $(DEPS)

%.o: %.asm
	$(AS) $< -c -o $@

check: $(KERNEL)
	./check.sh

run: $(KERNEL)
	qemu-system-$(ARCH) -machine virt -bios none -kernel $(KERNEL) -nographic

debug: $(KERNEL)
	qemu-system-$(ARCH) -machine virt -bios none -kernel $(KERNEL) -nographic -s -S

BINUTILS_DIR := binutils-$(BINUTILS_VER)
GCC_DIR := gcc-$(GCC_VER)
GDB_DIR := gdb-$(GDB_VER)

$(BINUTILS_DIR).tar.xz:
	curl -o $@.tmp https://ftp.gnu.org/gnu/binutils/$@ && mv $@.tmp $@

$(GDB_DIR).tar.xz:
	curl -o $@.tmp https://ftp.gnu.org/gnu/gdb/$@ && mv $@.tmp $@

$(GCC_DIR).tar.xz:
	curl -o $@.tmp https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VER)/$@ && mv $@.tmp $@

%: %.tar.xz
	tar -xf $<

$(BINUTILS_DIR)/Makefile: $(BINUTILS_DIR)
	cd $(BINUTILS_DIR) && \
	./configure \
		--prefix=$(PWD)/$(DEVTOOLS_DIR) \
		--target=$(TARGET) \
		--with-sysroot \
		--disable-nls \
		--disable-werror
	touch $@

$(DEVTOOLS_DIR)/bin/$(TARGET)-as: $(BINUTILS_DIR)/Makefile
	make -C $(BINUTILS_DIR)
	make -C $(BINUTILS_DIR) install

binutils: $(DEVTOOLS_DIR)/bin/$(TARGET)-as

$(GDB_DIR)/Makefile: binutils $(GDB_DIR)
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) cd $(GDB_DIR) && \
	./configure \
		--prefix=$(PWD)/$(DEVTOOLS_DIR) \
		--target=$(TARGET) \
		--disable-werror
	touch $@

$(DEVTOOLS_DIR)/bin/$(TARGET)-gdb: binutils $(GDB_DIR)/Makefile
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(GDB_DIR) all-gdb
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(GDB_DIR) install-gdb

gdb: $(DEVTOOLS_DIR)/bin/$(TARGET)-gdb

$(BUILD_DIR)/gcc/Makefile: binutils $(GCC_DIR)
	mkdir -p $(BUILD_DIR)/gcc
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) cd $(BUILD_DIR)/gcc && \
	$(CURDIR)/$(GCC_DIR)/configure \
		--prefix=$(PWD)/$(DEVTOOLS_DIR) \
		--target=$(TARGET) \
		--disable-nls \
		--enable-languages=c \
		--without-headers
	touch $@

$(DEVTOOLS_DIR)/bin/$(TARGET)-gcc: binutils $(BUILD_DIR)/gcc/Makefile
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(BUILD_DIR)/gcc all-gcc
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(BUILD_DIR)/gcc all-target-libgcc
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(BUILD_DIR)/gcc install-gcc
	PATH=$(PWD)/$(DEVTOOLS_DIR)/bin:$(PATH) make -C $(BUILD_DIR)/gcc install-target-libgcc

gcc: $(DEVTOOLS_DIR)/bin/$(TARGET)-gcc

.PHONY: clean_devtools
clean_devtools:
	rm -rf $(DEVTOOLS_DIR)

.PHONY: clean
clean:
	rm -f $(OBJS) $(KERNEL) $(DEPS)
