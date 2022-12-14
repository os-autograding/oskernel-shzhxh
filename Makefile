TIMEOUT ?= 60
ARCH ?= riscv64
FS ?= sfs

IMG_NAME := $(FS)_$(ARCH).img
IMG_URL := https://github.com/classroom-test-v/testsuits-in-one/raw/gh-pages/$(IMG_NAME)

build:
	cd kernel/zCore && make MODE=release LINUX=1 TEST=1 ARCH=$(ARCH)
	cp kernel/target/$(ARCH)/release/zcore.bin ./kernel-qemu

run:
	if [ ! -f $(IMG_NAME) ]; then wget $(IMG_URL); fi
	# busybox测试
	qemu-system-$(ARCH) -machine virt  -smp 1 -m 256M -append "LOG=error:ROOTPROC=busybox?sh?busybox_testcode.sh" -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic | tee qemu_run_output.txt
	# libc-test测试
	qemu-system-$(ARCH) -machine virt  -smp 1 -m 256M -append "LOG=error:ROOTPROC=busybox?sh?run-dynamic.sh" -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic | tee -a qemu_run_output.txt
	qemu-system-$(ARCH) -machine virt  -smp 1 -m 512M -append "LOG=error:ROOTPROC=busybox?sh?run-static.sh" -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic | tee -a qemu_run_output.txt
	# lua测试
	qemu-system-$(ARCH) -machine virt  -smp 1 -m 512M -append "LOG=error:ROOTPROC=busybox?sh?lua_testcode.sh" -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic | tee -a qemu_run_output.txt
	# lmbench测试
	qemu-system-$(ARCH) -machine virt  -smp 1 -m 512M -append "LOG=error:ROOTPROC=/bin/busybox?sh?lmbench_testcode.sh" -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic
