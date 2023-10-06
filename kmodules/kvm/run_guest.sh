#!/bin/bash

#CPU=cortex-a57
CPU=neoverse-n1
#CPU=max # not support on home PC

SMP="-smp 1"
DBG=""

DBG_EN=0

kernel_arg="noinitrd nokaslr"
# bellow three args test ok on home PC
#crash_arg="crashkernel=256M"
#dyn_arg="vfio.dyndbg=+pflmt irq_gic_v3_its.dyndbg=+pflmt iommu.dyndbg=+pflmt irqdomain.dyndbg=+pflmt"
#debug_arg="loglevel=8 sched_debug"

if [ $DBG_EN -eq 1 ] ; then
	echo "Enable qemu debug server"
	DBG="-s -S"
	SMP=""
fi

qemu-system-aarch64 -cpu $CPU -M virt,gic-version=3,its=on,iommu=smmuv3,accel=kvm \
			-m 1024 $SMP -kernel ./Image \
			-drive file=./rootfs_busybox_arm64.ext4,if=none,id=blk1,format=raw \
			-device virtio-blk-device,drive=blk1 \
	                -append "rootwait root=/dev/vda console=ttyAMA0,38400 keep_bootcon $kernel_arg $crash_arg $dyn_arg $debug_arg" \
			-nographic \
			--fsdev local,id=kmod_dev,path=$PWD/share,security_model=none -device virtio-9p-device,fsdev=kmod_dev,mount_tag=kmod_mount \
			$DBG
