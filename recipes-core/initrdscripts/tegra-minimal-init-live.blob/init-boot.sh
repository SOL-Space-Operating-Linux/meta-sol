#!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin


#SOL Version

mount -t proc proc /proc
mount -t devtmpfs none /dev
mount -t sysfs sysfs /sys

#create ramdisk
echo "Creating ram disk" > /dev/kmsg
mkdir -p /mnt/ramdisk
echo "Made directory" > /dev/kmsg
mount -t tmpfs -o size=${ROOTFSPART_SIZE} tmpfs /mnt/ramdisk
echo "Mounted" > /dev/kmsg

rootdev=""
opt="rw"
wait=""
start_boot_partition="1"

function mount_and_checksum() {
	echo "Mounting ${1} at /mnt/rootfs" > /dev/kmsg
	mkdir -p /mnt/rootfs
	dd if=$1 bs=512 skip=$skips5 count=$counts5 | head -c $sizes5 > /mnt/rootfs/live_rootfs.tar
	mount_rc=$?
	if [ ${mount_rc} -eq 0 ]; then
		cd /
		extract_and_boot /mnt/rootfs/live_rootfs.tar
		umount /mnt/ramdisk
		mount -t tmpfs -o size=${ROOTFSPART_SIZE} tmpfs /mnt/ramdisk
	else
		echo "Unable to mount ${1} with code (${mount_rc}), switching sides" > /dev/kmsg
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
skips1=0
skips2=2
skips3=90003
skips4=92004
skips5=98005

hash_skips1=1
hash_skips2=90002
hash_skips3=92003
hash_skips4=98004
hash_skips5=7998005

sizes1=60 # don't know rest yet

counts1=1
counts2=90000
counts3=2000
counts4=6000
counts5=7900000

for i in 1 2 3 4 5; do
	good1=0
    good2=0
    good3=0

    echo "Checking file $i" > /dev/kmsg

	for j in 1 2 3; do
		calculated=$(eval dd if="/dev/mmcblk0p\${j}" skip=\$skips$i count=\$counts$i | eval head -c \$sizes$i | md5sum | head -c 32)
		existing=$(eval dd if="/dev/mmcblk0p\${j}" skip=\$hash_skips$i count=1 | head -c 32)
		if [ $calculated = $existing ]; then
			eval good$j=1
            echo "file $i version $j matches hash" > /dev/kmsg
		else
            echo "file $i version $j does not match hash" > /dev/kmsg
        fi
	done

	if [ "$good1 $good2 $good3" = "0 0 0" ]; then
        echo "doing boot-tmr" > /dev/kmsg
		eval boot-tmr \$sizes$i \$skips$i /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3
	elif [ "$good1 $good2 $good3" != "1 1 1" ]; then
		# find good copy
        echo "finding good copy" > /dev/kmsg
		if [ $good1 = 1 ]; then
			g=1
		elif [ $good2 = 1 ]; then
			g=2
		else
			g=3
		fi

        echo "good image is $g; replacing bad ones" > /dev/kmsg
		# replace bad copy/copies
		for c in 1 2 3; do
			if [ $(eval echo \$good$c) = 0 ]; then
				eval dd if="/dev/mmcblk0p\${g}" of="/dev/mmcblk0p\${c}" skip=\$skips$i seek=\$skips$i count=\$counts$i
			fi
		done
	fi

    echo "replacing hashes and storing in flash" > /dev/kmsg
	# replace hashes
	echo $(eval dd if="/dev/mmcblk0p1" skip=\$skips$i count=\$counts$i | eval head -c \$sizes$i | md5sum | head -c 32) > md5.txt
	for j in 1 2 3; do
		echo $(eval dd if=md5.txt of="/dev/mmcblk0p\$j" seek=\$hash_skips$i count=1 | head -c 32)
	done


	if [ $i = 1 ]; then
		# fill in sizes after info is done
		sizes2=$(dd if=/dev/mmcblk0p1 skip=0 count=1 bs=512 | head -c 15 | tail -c 15)
		echo "sizes2 is $sizes2" > /dev/kmsg
		sizes3=$(dd if=/dev/mmcblk0p1 skip=0 count=1 bs=512 | head -c 30 | tail -c 15)
		echo "sizes3 is $sizes3" > /dev/kmsg
		sizes4=$(dd if=/dev/mmcblk0p1 skip=0 count=1 bs=512 | head -c 45 | tail -c 15)
		echo "sizes4 is $sizes4" > /dev/kmsg
		sizes5=$(dd if=/dev/mmcblk0p1 skip=0 count=1 bs=512 | head -c 60 | tail -c 15)
		echo "sizes5 is $sizes5" > /dev/kmsg
		echo $(dd if=/dev/mmcblk0p1 skip=0 count=1 bs=512) > /dev/kmsg
	fi
done

# Configure/Check config and data partitions
fsck -t ext4 /dev/mmcblk0p4
retval=$?
if [ $retval = 0 ]; then
	echo "ext4 file system exists and is fine for config partition" > /dev/kmsg
elif [ $retval = 1 ]; then
	echo "Errors successfully corrected on config partition" > /dev/kmsg
else
	echo "Config filesystem does not exist or is too corrupt, making fs" > /dev/kmsg
	mke2fs -t ext4 /dev/mmcblk0p4 > /dev/kmsg
fi
mkdir /mnt/ramdisk/config
mount -t ext4 /dev/mmcblk0p4 /mnt/ramdisk/config

fsck -t ext4 /dev/mmcblk0p5
retval=$?
if [ $retval = 0 ]; then
	echo "ext4 file system exists and is fine for data partition" > /dev/kmsg
elif [ $retval = 1 ]; then
	echo "Errors successfully corrected on data partition" > /dev/kmsg
else
	echo "Data filesystem does not exist or is too corrupt, making fs" > /dev/kmsg
	mke2fs -t ext4 /dev/mmcblk0p5 > /dev/kmsg
fi
mkdir /mnt/ramdisk/data
mount -t ext4 /dev/mmcblk0p5 /mnt/ramdisk/data

while true; do
	boot_device="/dev/mmcblk0p${boot_partition}"
	echo "Attempting to boot from ${boot_device}" > /dev/kmsg
	mount_and_checksum "${boot_device}"
	sh
	echo "Boot from ${boot_device} failed" > /dev/kmsg
	boot_partition=$((${boot_partition} + 1 % ${num_paritions}))
done





