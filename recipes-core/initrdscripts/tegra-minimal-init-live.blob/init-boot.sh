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
tar_offset="97005"

function mount_and_checksum() {
	echo "Mounting ${1} at /mnt/rootfs" > /dev/kmsg
	mkdir -p /mnt/rootfs
	head -c 60 $1 | tail -c 15
	dd if=$1 of=/mnt/rootfs/live_rootfs.tar bs=512 skip=$tar_offset 
	mount_rc=$?
	if [ ${mount_rc} -eq 0 ]; then
		cd /
		extract_and_boot /mnt/rootfs/live_rootfs.tar
		umount /mnt/ramdisk
		umount /mnt/rootfs
		mount -t tmpfs -o size=${ROOTFSPART_SIZE} tmpfs /mnt/ramdisk
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


num_paritions="3"
boot_partition=${start_boot_partition}


#do majority vote here
skips=(0 2 90003 92004 97005) #blocks
hash_skips=(1 90002 92003 97004 1597008) #blocks
sizes=(60) #bytes
counts=(1 90000 2000 5000 1500000) #blocks

for i in {1..5}; do
	good=(0 0 0)

	for j in {1..3}; do
		calculated=$(dd if="/dev/mmcblk0p${j}" skip=$skips[$i] count=$counts[$i] 2>/dev/null | head -c $sizes[$i] | md5sum | head -c 32)
		existing=$(dd if="/dev/mmcblk0p${j}" skip=$hash_skips[$i] count=1 2>/dev/null | head -c 32)
		if [ $calculated = $existing ]; then
			$good[$j]=1
		fi
	done

	if [ "$good" = "0 0 0" ]; then
		boot-tmr $sizes[$i] $skips[$i] /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
	elif [ "$good" != "1 1 1" ]; then
		# find good copy
		if [ $good[1] = 1 ]; then
			g=1
		elif [ $good[2] = 1 ]; then
			g=2
		else
			g=3
		fi

		# replace bad copy/copies
		for c in {1..3}; do
			if [ $good[$c] = 0 ]; then
				dd if="/dev/mmcblk0p${g}" of="/dev/mmcblk0p${c}" skip=$skips[$i] seek=$skips[$i] count=$counts[$i]
			fi
		done
	fi

	# replace hashes
	echo $(dd if="/dev/mmcblk0p1" skip=$skips[$i] count=$counts[$i] 2>/dev/null | head -c $sizes[$i] | md5sum | head -c 32) > md5.txt
	for j in {1..3}; do
		echo $(dd if=md5.txt of="/dev/mmcblk0p{$j}" seek=$hash_skips[$i] count=1 2>/dev/null | head -c 32)
	done


	if [ $i = 1 ]; then
		# fill in sizes after info is done
		sizes+=$(dd if="/dev/mmcblk0p1" skip=0 count=1 2>/dev/null | head -c 15 | tail -c 15)
		sizes+=$(dd if="/dev/mmcblk0p1" skip=0 count=1 2>/dev/null | head -c 30 | tail -c 15)
		sizes+=$(dd if="/dev/mmcblk0p1" skip=0 count=1 2>/dev/null | head -c 45 | tail -c 15)
		sizes+=$(dd if="/dev/mmcblk0p1" skip=0 count=1 2>/dev/null | head -c 60 | tail -c 15)
	fi
done

# boot-tmr $size $skip $file1 $file2 $file3

while true; do
	boot_device="/dev/mmcblk0p${boot_partition}"
	echo "Attempting to boot from ${boot_device}" > /dev/kmsg
	mount_and_checksum "${boot_device}"
	echo "Boot from ${boot_device} failed" > /dev/kmsg
	boot_partition=$((${boot_partition} + 1 % ${num_paritions}))
done





