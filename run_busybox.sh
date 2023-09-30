#!/bin/bash

LROOT=$PWD
ROOTFS_X86=_install_x86
ROOTFS_ARM32=_install_arm32
ROOTFS_ARM64=_install_arm64
CONSOLE_DEV_NODE=dev/console

#CPU=cortex-a57
CPU=neoverse-n1
#CPU=max # not support on home PC

kernel_arg="noinitrd nokaslr"
# bellow three args test ok on home PC
#crash_arg="crashkernel=256M"
#dyn_arg="vfio.dyndbg=+pflmt irq_gic_v3_its.dyndbg=+pflmt iommu.dyndbg=+pflmt irqdomain.dyndbg=+pflmt"
#debug_arg="loglevel=8 sched_debug"

if [ $# -lt 1 ]; then
	echo "Usage: $0 [arch] [debug]"
fi

if [ $# -eq 2 ] && [ $2 == "debug" ]; then
	echo "Enable GDB debug mode"
	DBG="-s -S"
fi

case $1 in
	x86_64)
		if [ ! -c $LROOT/$ROOTFS_X86/$CONSOLE_DEV_NODE ]; then
			echo "please create console device node first, and recompile kernel"
			exit 1
		fi
		qemu-system-x86_64 -kernel arch/x86/boot/bzImage \
				   -append "rdinit=/linuxrc console=ttyS0" -nographic \
				   --virtfs local,id=kmod_dev,path=$PWD/kmodules,security_model=none,mount_tag=kmod_mount \
				   $DBG ;;
	x86)
		if [ ! -c $LROOT/$ROOTFS_X86/$CONSOLE_DEV_NODE ]; then
			echo "please create console device node first, and recompile kernel"
			exit 1
		fi
		qemu-system-i386 -kernel arch/x86/boot/bzImage \
				 -append "rdinit=/linuxrc console=ttyS0" -nographic \
				 --virtfs local,id=kmod_dev,path=$PWD/kmodules,security_model=none,mount_tag=kmod_mount \
				 $DBG ;;
	arm32)
		if [ ! -c $LROOT/$ROOTFS_ARM32/$CONSOLE_DEV_NODE ]; then
			echo "please create console device node first, and recompile kernel"
			exit 1
		fi
		qemu-system-arm -M vexpress-a9 -smp 4 -m 100M -kernel arch/arm/boot/zImage \
				-dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic \
				-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8 slub_debug kmemleak=on" \
				--fsdev local,id=kmod_dev,path=$PWD/kmodules,security_model=none -device virtio-9p-device,fsdev=kmod_dev,mount_tag=kmod_mount \
				$DBG ;;
	arm64)
		if [ ! -c $LROOT/$ROOTFS_ARM64/$CONSOLE_DEV_NODE ]; then
			echo "please create console device node first, and recompile kernel"
			exit 1
		fi
		qemu-system-aarch64 -cpu $CPU -M virt,gic-version=3,its=on,iommu=smmuv3 \
			-m 100 -smp 2 -kernel arch/arm64/boot/Image \
			-drive file=./rootfs_busybox_arm64.ext4,if=none,id=blk1,format=raw \
			-device virtio-blk-device,drive=blk1 \
	                -append "rootwait root=/dev/vda console=ttyAMA0,38400 keep_bootcon $kernel_arg $crash_arg $dyn_arg $debug_arg" \
			-nographic \
			--fsdev local,id=kmod_dev,path=$PWD/kmodules,security_model=none -device virtio-9p-device,fsdev=kmod_dev,mount_tag=kmod_mount \
			$DBG ;;
esac
