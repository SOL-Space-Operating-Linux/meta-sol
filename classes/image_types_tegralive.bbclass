inherit image_types pythonnative perlnative



IMAGE_TYPES += "ext4.live"
LIVE_IMAGE_COMPRESSION ?= "none"

IMAGE_ROOTFS_ALIGNMENT ?= "4"
IMAGE_ROOTFS_TMP = "${WORKDIR}/ROOTFS_TMP"


IMAGE_NAME_SUFFIX ??= ".rootfs"

# The default aligment of the size of the rootfs is set to 1KiB. In case
# you're using the SD card emulation of a QEMU system simulator you may
# set this value to 2048 (2MiB alignment).
IMAGE_ROOTFS_ALIGNMENT ?= "1"


oe_mkext234fs () {
	fstype=$1
	extra_imagecmd=""

	if [ $# -gt 1 ]; then
		shift
		extra_imagecmd=$@
	fi

	# If generating an empty image the size of the sparse block should be large
	# enough to allocate an ext4 filesystem using 4096 bytes per inode, this is
	# about 60K, so dd needs a minimum count of 60, with bs=1024 (bytes per IO)
	eval local COUNT=\"0\"
	eval local MIN_COUNT=\"60\"
	if [ $ROOTFS_SIZE -lt $MIN_COUNT ]; then
		eval COUNT=\"$MIN_COUNT\"
	fi
	# Create a sparse image block
	bbdebug 1 Executing "dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live seek=$ROOTFS_SIZE count=$COUNT bs=1024"
	dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live seek=$ROOTFS_SIZE count=$COUNT bs=1024
	bbdebug 1 "Actual Rootfs size:  `du -s ${IMAGE_ROOTFS}`"
	bbdebug 1 "Actual Partion size: `stat -c '%s' ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live`"
	
    bbdebug 1 "tar -cJf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar --numeric-owner -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]"

	#Choose your compression algorithm here
	if [ ${LIVE_IMAGE_COMPRESSION} == "xz" ]; then
    	tar -cJf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar --numeric-owner -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]
	else
		tar -cf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar --numeric-owner -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]
	fi

	rm -rf ${IMAGE_ROOTFS_TMP}
	mkdir -p ${IMAGE_ROOTFS_TMP}
	cp -r ${IMAGE_ROOTFS}/boot ${IMAGE_ROOTFS_TMP}/boot
	cp -r ${IMAGE_ROOTFS}/boot ${IMAGE_ROOTFS_TMP}/boot1
	cp -r ${IMAGE_ROOTFS}/boot ${IMAGE_ROOTFS_TMP}/boot2
	mkdir -p ${IMAGE_ROOTFS_TMP}/boothash/extlinux
	for file in ${IMAGE_ROOTFS_TMP}/boot/* ${IMAGE_ROOTFS_TMP}/boot/*/*; do
		if [ -f "${file}" ]; then
			md5sum $file > ${IMAGE_ROOTFS_TMP}/boothash/${file#"${IMAGE_ROOTFS_TMP}/boot/"} #parallel directory structure
		fi
	done

	touch ${IMAGE_ROOTFS_TMP}/info
	for file in Image u-boot-dtb.bin initrd; do
		name=$(basename $(realpath ${IMAGE_ROOTFS_TMP}/boot/${file}))
		size=$(wc -c ${IMAGE_ROOTFS_TMP}/boot/${name} | awk '{print $1}')
		for item in $name $size; do
			printf $item >> ${IMAGE_ROOTFS_TMP}/info
			len=${#item}
			while [ $len -lt 100 ]; do
				#Pad with null characters so every entity is 20 bytes
				printf '\0' >> ${IMAGE_ROOTFS_TMP}/info 
				len=`expr $len + 1`
			done
		done
	done

    cp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar ${IMAGE_ROOTFS_TMP}/live_rootfs.tar

	#Choose your hash algorithm here
	cd ${IMAGE_ROOTFS_TMP}
	sha256sum live_rootfs.tar > live_rootfs.sha256
	cd -

    bbdebug 1 Executing "mkfs.$fstype -F $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live -d ${IMAGE_ROOTFS_TMP}"
	mkfs.$fstype -F -O ^metadata_csum $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live -d ${IMAGE_ROOTFS_TMP}
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	fsck.$fstype -pvfD ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype.live || [ $? -le 3 ]
}

IMAGE_CMD_ext4.live = "oe_mkext234fs ext4 ${EXTRA_IMAGECMD}"

EXTRA_IMAGECMD_ext4.live ?= "-i 4096"
do_image_ext4.live[depends] += "e2fsprogs-native:do_populate_sysroot"
