#!/bin/sh

################################################################################
# MAIN FUNCTION
################################################################################
# Our main function that executes when init-boot.sh is called by initrd
main(){

  #make sure our path is set appropriately
  PATH=/sbin:/bin:/usr/sbin:/usr/bin
  
  # Copied from SOL Version
  mount -t proc proc /proc
  mount -t devtmpfs none /dev
  mount -t sysfs sysfs /sys
  mkdir /tmr
  
  # Create ramdisk
  echo "Creating ram disks" > /dev/kmsg
  mkdir -p /mnt/ramdisk
  echo "Made directory /mnt/ramdisk" > /dev/kmsg
  mount -t tmpfs -o size=ROOTFSPART_SIZE tmpfs /mnt/ramdisk
  echo "Mounted" > /dev/kmsg
  
  rootdev=""
  opt="rw"
  wait=""
  start_boot_partition="1"
  
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
  
  # Set up the variables needed to do the TMR checks and corrections 
  num_partitions="3"
  boot_partition=${start_boot_partition}

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
  
  counts1=INFO_FILE_BLOCKS
  counts2=IMAGE_FILE_BLOCKS
  counts3=DTB_FILE_BLOCKS
  counts4=INITRD_FILE_BLOCKS
  counts5=ROOTFS_FILE_BLOCKS

  partsize=ROOTFSPART_SIZE

  # We only know the size of the first file. Obtain the other four once we know
  # the info file is good
  sizes1=$(echo INFO_BYTES \* 4 | bc)

  # Loop over the five files in the blob. We read the "file$i" in with the 
  # tail/head command in the checksum function
  for i in 1 2 3 4 5; do

    # Keep track of which of the three files are good. Note that good# is 
    # used for both the file name (stored in /) and variable name
    good1="-"; good2="-"; good3="-"
    echo "Checking file $i" > /dev/kmsg

    # Attempt to do the checksums in parallel 
    for j in 1 2 3; do
      echo -n "-" > /tmr/good$j
      echo -n "-" > /tmr/hash$j
      checksum $i $j &
    done

    # Now wait until they are finished
    for j in 1 2 3; do
      good="-"
      while [ $good = "-" ]; do
        sleep 0.1
        good=`cat /tmr/good$j`
      done
      eval good$j=$good
    done 

    # Case A) None of the three copies was good! Do boot-tmr
    if [ "$good1 $good2 $good3" = "0 0 0" ]; then
      echo "Performing boot-tmr" > /dev/kmsg
      echo "Making sure!" > /dev/kmsg
      eval size=\$sizes$i
      eval skip=\$skips$i
      boot-tmr $size /tmr/file1 /tmr/file2 /tmr/file3 /tmr/file

      # Replace BLOBs and hashes in flash
      md5sum /tmr/file | head -c 32 > /tmr/hash
      for c in 1 2 3; do
        echo "Replacing bad copy: $c" > /dev/kmsg
        eval dd if=/tmr/file of="/dev/mmcblk0p\${c}" seek=\$skips$i \
          count=\$counts$i 2>/dev/null
        eval dd if=/tmr/hash of="/dev/mmcblk0p\${c}" seek=\$hash_skips$i \
          count=1 2>/dev/null
      done
 
    # Case B) We had at least one good copy. Use that to replace the others
    elif [ "$good1 $good2 $good3" != "1 1 1" ]; then
      echo "Finding good copy" > /dev/kmsg
      if [ $good1 = 1 ]; then
        g=1; mv /tmr/file1 /tmr/file; mv /tmr/hash1 /tmr/hash
      elif [ $good2 = 1 ]; then
        g=2; mv /tmr/file2 /tmr/file; mv /tmr/hash2 /tmr/hash
      else
        g=3; mv /tmr/file3 /tmr/file; mv /tmr/hash3 /tmr/hash
      fi
  
      # Replace bad copy/copies
      echo "Good image found in $g; using it to replace bad ones" > /dev/kmsg
      for c in 1 2 3; do
        if [ $(eval echo \$good$c) = 0 ]; then
          echo "replacing bad copy: $c" > /dev/kmsg
          eval dd if=/tmr/file of="/dev/mmcblk0p\${c}" seek=\$skips$i \
            count=\$counts$i 2>/dev/null
          eval dd if=/tmr/hash of="/dev/mmcblk0p\${c}" seek=\$hash_skips$i \
            count=1 2>/dev/null
        fi
      done

    # Case C) All three copies were good
    else
      echo "All three copies were good" > /dev/kmsg
      mv /tmr/file1 /tmr/file
    fi
 
    # If this is the first file, we pull the sizes of the remaining four files 
    # and print out information to the console
    if [ $i = 1 ]; then
      echo -e "Contents of info file : \n" > /dev/kmsg
      echo $(cat /tmr/file) > /dev/kmsg
      sizes2=$(cat /tmr/file | head -c INFO_BYTES | tail -c INFO_BYTES)
      echo "sizes2 is $sizes2" > /dev/kmsg
      sizes3=$(cat /tmr/file | head -c $(echo INFO_BYTES \* 2 | bc) | tail -c INFO_BYTES)
      echo "sizes3 is $sizes3" > /dev/kmsg
      sizes4=$(cat /tmr/file | head -c $(echo INFO_BYTES \* 3 | bc) | tail -c INFO_BYTES)
      echo "sizes4 is $sizes4" > /dev/kmsg
      sizes5=$(cat /tmr/file | head -c $(echo INFO_BYTES \* 4 | bc) | tail -c INFO_BYTES)
      echo "sizes5 is $sizes5" > /dev/kmsg
    fi
  done
  
  # Create /etc/mtab so we can use e2fsck and resize2fs
  ln -s /proc/mounts /etc/mtab
 
  # Check and configure config partition. Resize image to full partition size if 
  # we have just flashed
  echo "Attempting to mount config partition..." > /dev/kmsg
  e2fsck -f /dev/mmcblk0p4
  retval=$?
  if [ $retval = 0 ]; then
    echo "ext4 file system exists and is fine for config partition" > /dev/kmsg
    resize2fs /dev/mmcblk0p4 > /dev/kmsg
  elif [ $retval = 1 ]; then
    echo "Errors successfully corrected on config partition" > /dev/kmsg
  else
    echo "Config filesystem does not exist or is too corrupt, making fs" > /dev/kmsg
    mke2fs -t ext4 /dev/mmcblk0p4 > /dev/kmsg
  fi
  mkdir /mnt/ramdisk/config
  mount -t ext4 /dev/mmcblk0p4 /mnt/ramdisk/config

  # Check and configure data partition. Resize image to full partition size if
  # we have just flashed
  echo "Attempting to mount data partition..." > /dev/kmsg
  e2fsck -f ext4 /dev/mmCheck and configurecblk0p5
  retval=$? 
  if [ $retval = 0 ]; then
    echo "ext4 file system exists and is fine for data partition" > /dev/kmsg
    resize2fs /dev/mmcblk0p5 > /dev/kmsg
  elif [ $retval = 1 ]; then
    echo "Errors successfully corrected on data partition" > /dev/kmsg
  else
    echo "Data filesystem does not exist or is too corrupt, making fs" > /dev/kmsg
    mke2fs -t ext4 /dev/mmcblk0p5 > /dev/kmsg
  fi
  mkdir /mnt/ramdisk/data
  mount -t ext4 /dev/mmcblk0p5 /mnt/ramdisk/data
 
  # Attempt to start from partition 1, then 2, then 3
  while true; do
    boot_device="/dev/mmcblk0p${boot_partition}"
    echo "Attempting to boot from ${boot_device}" > /dev/kmsg
    mount_and_launch "${boot_device}"
    echo "Boot from ${boot_device} failed" > /dev/kmsg
    boot_partition=$((${boot_partition} + 1 % ${num_partitions}))
  done
}

################################################################################
# Checksum function - compares checksums, writes /tmr/file# and /tmr/hash#
################################################################################
function checksum() {

  # i is the file number and j is the copy number
  i=$1; j=$2

  # Get some temporary variables (f=file; h=hash)
  part="/dev/mmcblk0p${j}"
  eval size=\$sizes$i
  eval skip_f=\$skips$i
  eval skip_h=\$hash_skips$i
  toff_f=`echo $partsize - $skip_f \* 512 | bc`
  toff_h=`echo $partsize - $skip_h \* 512 | bc`

  # Retrieve the file, leave it in memory at /file$j, and calculate the md5sum
  tail -c $toff_f $part | head -c $size > /tmr/file$j
  calculated=$(md5sum /tmr/file$j | head -c 32)

  # Compare it to the md5sum stored, leaving the hash at /hash$j
  tail -c $toff_h $part | head -c 32 > /tmr/hash$j  
  existing=$(head -c 32 /tmr/hash$j)
  if [ $calculated = $existing ]; then
    echo -n "1" > /tmr/good$j
    echo "file $i version $j matches hash" > /dev/kmsg
  else
    echo -n "0" > /tmr/good$j
    echo "file $i version $j does not match hash" > /dev/kmsg
    echo "Calculated md5sum = $calculated" > /dev/kmsg
    echo "Existing md5sum   = $existing" > /dev/kmsg
    rm /tmr/hash$j
  fi

} 

################################################################################
# mount_and_launch - Mount the root filesystem contained in /tmr/file
################################################################################
function mount_and_launch() {
  echo "Mounting ${1} at /mnt/rootfs" > /dev/kmsg
  mkdir -p /mnt/rootfs
  mv /tmr/file /mnt/rootfs/live_rootfs.tar
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

################################################################################
# extract_and_boot - Extract the rootfs from the tar file and init 
################################################################################
function extract_and_boot() {
  echo "Starting ramdisk extraction" > /dev/kmsg
  tar -xmf $1 -C /mnt/ramdisk
  tar_rc=$?
  if [ ${tar_rc} -ne 0 ]; then
    echo "Decompression failed of file ${1} with code (${tar_rc})" > /dev/kmsg
  else
    echo "Ramdisk extraction completed" > /dev/kmsg
    mount --move /sys  /mnt/ramdisk/sys
    mount --move /proc /mnt/ramdisk/proc
    mount --move /dev  /mnt/ramdisk/dev
    exec switch_root /mnt/ramdisk /sbin/init
  fi
}

# Execute main
main "$@"; exit

