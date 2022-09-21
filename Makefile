TIMEOUT ?= 100
ARCH ?= riscv64
FS ?= sfs

IMG_NAME := $(FS)_$(ARCH).img
IMG_URL := https://github.com/classroom-test-v/testsuits-in-one/raw/gh-pages/$(IMG_NAME)

build:
	cd kernel/zCore && make MODE=release LINUX=1 TEST=1 ARCH=$(ARCH)
	cp kernel/target/riscv64/release/zcore.bin ./kernel-qemu

run:
	if [ ! -f $(IMG_NAME) ]; then wget $(IMG_URL); fi
	# timeout $(TIMEOUT) qemu-system-riscv64 -machine virt -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic -smp 1 -m 128m | tee qemu_run_output.txt
	qemu-system-riscv64 -machine virt -drive file=$(IMG_NAME),if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -kernel kernel-qemu -nographic -smp 1 -m 128m