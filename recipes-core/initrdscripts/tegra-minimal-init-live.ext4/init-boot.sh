#!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin


#SOL Version

mount -t proc proc /proc
mount -t devtmpfs none /dev
mount -t sysfs sysfs /sys

#create ramdisk
echo "Creating ram disk" > /dev/kmsg
mkdir -p /mnt/ramdisk
mount -t tmpfs -o size=${ROOTFSPART_SIZE} tmpfs /mnt/ramdisk

rootdev=""
opt="rw"
wait=""
start_boot_partition="1"

function mount_and_checksum() {
	echo "Mounting ${1} at /mnt/rootfs" > /dev/kmsg
	mkdir -p /mnt/rootfs
	mount -t ext4 -o "$opt" "${1}" /mnt/rootfs
	mount_rc=$?
	if [ ${mount_rc} -eq 0 ]; then
		cd /mnt/rootfs/
		sha256sum -c live_rootfs.sha256
		checksum_rc=$?
		cd /
		if [ ${checksum_rc} -eq 0 ]; then
			extract_and_boot /mnt/rootfs/live_rootfs.tar
			umount /mnt/ramdisk
			umount /mnt/rootfs
			mount -t tmpfs -o size=${ROOTFSPART_SIZE} tmpfs /mnt/ramdisk
		else
			echo "Sha256 checksum failed for ${1} with code (${checksum_rc}), switching sides" > /dev/kmsg
			unmount /mnt/rootfs
		fi
	else
		echo "Unable to mount ${1} with code (${mount_rc}), switching sides" > /dev/kmsg
		umount /mnt/rootfs
	fi
}

function extract_and_boot() {
	echo "Starting ramdisk extraction" > /dev/kmsg
	tar -xf $1 -C /mnt/ramdisk
	tar_rc=$?
	if [ ${tar_rc} -ne 0 ]; then
		echo "Uncompression failed of file ${1} with code (${tar_rc})" > /dev/kmsg
	else
		echo "Ramdisk extraction completed" > /dev/kmsg
		mount --move /sys  /mnt/ramdisk/sys
		mount --move /proc /mnt/ramdisk/proc
		mount --move /dev  /mnt/ramdisk/dev
		umount /mnt/rootfs
		exec switch_root /mnt/ramdisk /sbin/init
	fi
}


[ ! -f /etc/platform-preboot ] || . /etc/platform-preboot

if [ -z "$rootdev" ]; then
    for bootarg in `cat /proc/cmdline`; do
	case "$bootarg" in
	    root=*) rootdev="${bootarg##root=}" ;;
		sdhci_tegra.en_boot_part_access=*) start_boot_partition="${bootarg##sdhci_tegra.en_boot_part_access=}" ;;
	    ro) opt="ro" ;;
	    rootwait) wait="yes" ;;
	esac
    done
fi

if [ -n "$wait" -a ! -b "${rootdev}" ]; then
    echo "Waiting for ${rootdev}..."
    count=0
    while [ $count -lt 25 ]; do
	test -b "${rootdev}" && break
	sleep 0.1
	count=`expr $count + 1`
    done
fi


num_paritions="2"
boot_partition=${start_boot_partition}

while true; do
	boot_device="/dev/mmcblk0p${boot_partition}"
	echo "Attempting to boot from ${boot_device}" > /dev/kmsg
	mount_and_checksum "${boot_device}"
	echo "Boot from ${boot_device} failed" > /dev/kmsg
	boot_partition=$((${boot_partition} + 1 % ${num_paritions}))
done





