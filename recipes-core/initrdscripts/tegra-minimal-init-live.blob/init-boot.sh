#!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin


#SOL Version

mount -t proc proc /proc
mount -t devtmpfs none /dev
mount -t sysfs sysfs /sys

#create ramdisk
echo "Creating ram disks" > /dev/kmsg
mkdir -p /mnt/ramdisk
echo "Made directory" > /dev/kmsg
mount -t tmpfs -o size=ROOTFSPART_SIZE tmpfs /mnt/ramdisk
echo "Mounted" > /dev/kmsg

rootdev=""
opt="rw"
wait=""
start_boot_partition="1"

function mount_and_checksum() {
	echo "Mounting ${1} at /mnt/rootfs" > /dev/kmsg
	mkdir -p /mnt/rootfs
	mv file /mnt/rootfs/live_rootfs.tar #most recent "file" is the tar
	mount_rc=$?
	if [ ${mount_rc} -eq 0 ]; then
		cd /
		extract_and_boot /mnt/rootfs/live_rootfs.tar
		umount /mnt/ramdisk
		mount -t tmpfs -o size=ROOTFSPART_SIZE tmpfs /mnt/ramdisk
	else
		echo "Unable to mount ${1} with code (${mount_rc}), switching sides" > /dev/kmsg
	fi
}

function extract_and_boot() {
	echo "Starting ramdisk extraction" > /dev/kmsg
	tar -xmf $1 -C /mnt/ramdisk
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

echo "PRESS ANY KEY WITHIN 3 SECONDS TO STOP AUTOBOOT" > /dev/kmsg
read -n 1 -s -r -t 3
stop=$?
if [ ${stop} -eq 0 ]; then
	sh;
fi

num_paritions="3"
boot_partition=${start_boot_partition}

#do majority vote here
skips1=INFO_FILE_OFFSET
skips2=IMAGE_FILE_OFFSET
skips3=DTB_FILE_OFFSET
skips4=INITRD_FILE_OFFSET
skips5=ROOTFS_FILE_OFFSET

hash_skips1=INFO_HASH_OFFSET
hash_skips2=IMAGE_HASH_OFFSET
hash_skips3=DTB_HASH_OFFSET
hash_skips4=INITRD_HASH_OFFSET
hash_skips5=ROOTFS_HASH_OFFSET

sizes1=$(echo INFO_BYTES \* 4 | bc) # don't know rest yet

counts1=INFO_FILE_BLOCKS
counts2=IMAGE_FILE_BLOCKS
counts3=DTB_FILE_BLOCKS
counts4=INITRD_FILE_BLOCKS
counts5=ROOTFS_FILE_BLOCKS

partsize=ROOTFSPART_SIZE

function checksum() {
	i=$1
	j=$2

	# Get some temporary variables
	part="/dev/mmcblk0p${j}"
	eval size=\$sizes$i
	eval skip=\$skips$i
	toff=`echo $partsize - $skip \* 512 | bc`

	tail -c $toff $part | head -c $size > file$j
	calculated=$(md5sum file$j | head -c 32)
	existing=$(eval dd if="/dev/mmcblk0p\${j}" skip=\$hash_skips$i count=1 2>/dev/null | head -c 32)
	if [ $calculated = $existing ]; then
		eval echo "1" > good$j
		eval echo $existing > hash$j
		echo "file $i version $j matches hash" > /dev/kmsg
	else
		eval echo "0" > good$j
		echo "file $i version $j does not match hash" > /dev/kmsg
	fi
} 

for i in 1 2 3 4 5; do
	good1="-"
    good2="-"
    good3="-"

    echo "Checking file $i" > /dev/kmsg

	for j in 1 2 3; do
		eval echo "-" > good$j
		eval echo "-" > hash$j
		checksum $i $j &
	done

	for j in 1 2 3; do
		good="-"
		while [ $good = "-" ]; do
			sleep 0.1
			good=`cat good$j`
		done
		eval good$j=$good
	done

	if [ "$good1 $good2 $good3" = "0 0 0" ]; then
        echo "doing boot-tmr" > /dev/kmsg
		eval boot-tmr \$sizes$i \$skips$i /dev/mmcblk0p1 /dev/mmcblk0p2 /dev/mmcblk0p3 file

		# replace BLOBs and hashes in flash
		md5sum file | head -c 32 > hash
		for c in 1 2 3; do
			echo "replacing bad copy: $c" > /dev/kmsg
			eval dd if=file of="/dev/mmcblk0p\${c}" seek=\$skips$i count=\$counts$i 2>/dev/null
			eval dd if="hash" of="/dev/mmcblk0p\$c" seek=\$hash_skips$i count=1 2>/dev/null
		done

	elif [ "$good1 $good2 $good3" != "1 1 1" ]; then
		# find good copy
        echo "finding good copy" > /dev/kmsg
		if [ $good1 = 1 ]; then
			g=1
			mv file1 file
		elif [ $good2 = 1 ]; then
			g=2
			mv file2 file
		else
			g=3
			mv file3 file
		fi

        echo "good image is $g; replacing bad ones" > /dev/kmsg
		# replace bad copy/copies
		for c in 1 2 3; do
			if [ $(eval echo \$good$c) = 0 ]; then
				echo "replacing bad copy: $c" > /dev/kmsg
				eval dd if=file of="/dev/mmcblk0p\${c}" seek=\$skips$i count=\$counts$i 2>/dev/null
				eval dd if="hash\$g" of="/dev/mmcblk0p\$c" seek=\$hash_skips$i count=1 2>/dev/null
			fi
		done
	else
		echo "all good" > /dev/kmsg
		mv file1 file
	fi


	if [ $i = 1 ]; then
		# fill in sizes after info is done
		sizes2=$(cat file | head -c INFO_BYTES | tail -c INFO_BYTES)
		echo "sizes2 is $sizes2" > /dev/kmsg
		sizes3=$(cat file | head -c $(echo INFO_BYTES \* 2 | bc) | tail -c INFO_BYTES)
		echo "sizes3 is $sizes3" > /dev/kmsg
		sizes4=$(cat file | head -c $(echo INFO_BYTES \* 3 | bc) | tail -c INFO_BYTES)
		echo "sizes4 is $sizes4" > /dev/kmsg
		sizes5=$(cat file | head -c $(echo INFO_BYTES \* 4 | bc) | tail -c INFO_BYTES)
		echo "sizes5 is $sizes5" > /dev/kmsg
		echo $(cat file) > /dev/kmsg
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





