inherit image_types pythonnative perlnative



IMAGE_TYPES += "blob"
LIVE_IMAGE_COMPRESSION ?= "none"

IMAGE_ROOTFS_ALIGNMENT ?= "4"
IMAGE_ROOTFS_TMP = "${WORKDIR}/ROOTFS_TMP"


IMAGE_NAME_SUFFIX ??= ".rootfs"

# The default aligment of the size of the rootfs is set to 1KiB. In case
# you're using the SD card emulation of a QEMU system simulator you may
# set this value to 2048 (2MiB alignment).
IMAGE_ROOTFS_ALIGNMENT ?= "1"


oe_mkblobfs () {

	# Compress Image (Remove J flag for no compression)
    bbdebug 1 "tar -cJf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar --numeric-owner -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]"
    tar -cJf ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar --numeric-owner -C ${IMAGE_ROOTFS} . || [ $? -eq 1 ]

	rm -rf ${IMAGE_ROOTFS_TMP}
	mkdir -p ${IMAGE_ROOTFS_TMP}
	cp -r ${IMAGE_ROOTFS}/boot ${IMAGE_ROOTFS_TMP}/boot

    cp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.live.tar ${IMAGE_ROOTFS_TMP}/live_rootfs.tar

	# symbolic link for dtb
	ln -s ${IMAGE_ROOTFS_TMP}/boot/tegra*.dtb ${IMAGE_ROOTFS_TMP}/boot/dtb

	# Populate `info` file with sizes
	touch ${IMAGE_ROOTFS_TMP}/info
	for file in boot/Image boot/dtb boot/initrd live_rootfs.tar; do
		size=$(wc -c ${IMAGE_ROOTFS_TMP}/${file} | awk '{print $1}')
		printf "%015u" $size >> ${IMAGE_ROOTFS_TMP}/info
	done

	# Populate `hash/` directory with md5sums
	mkdir ${IMAGE_ROOTFS_TMP}/hash
	for file in info boot/dtb boot/initrd boot/Image live_rootfs.tar; do
		md5sum ${IMAGE_ROOTFS_TMP}/$file > ${IMAGE_ROOTFS_TMP}/hash/$(basename $file)
	done

	# Create the blob
	bbdebug 1 "Executing dd commands to build blob"
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/info seek=0 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/hash/info seek=1 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/boot/Image seek=2 count=90000 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/hash/Image seek=90002 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/boot/dtb seek=90003 count=2000 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/hash/dtb seek=92003 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/boot/initrd seek=92004 count=5000 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/hash/initrd seek=97004 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/live_rootfs.tar seek=97005 count=4500000 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=${IMAGE_ROOTFS_TMP}/hash/live_rootfs.tar seek=4597005 count=1 obs=512
	dd of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.blob if=/dev/zero seek=4597008 obs=512 count=0
}

IMAGE_CMD_blob = "oe_mkblobfs"

do_image_blob[depends] += "e2fsprogs-native:do_populate_sysroot"
