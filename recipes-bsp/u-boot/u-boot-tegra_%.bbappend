FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://tmr.diff"

do_compile_prepend() {

    sed -e "s/YOCTO_INFO_FILE_OFFSET/${INFO_FILE_OFFSET}/g" \
        -e "s/YOCTO_INFO_HASH_OFFSET/${INFO_HASH_OFFSET}/g" \
        -e "s/YOCTO_IMAGE_FILE_OFFSET/${IMAGE_FILE_OFFSET}/g" \
        -e "s/YOCTO_IMAGE_HASH_OFFSET/${IMAGE_HASH_OFFSET}/g" \
        -e "s/YOCTO_DTB_FILE_OFFSET/${DTB_FILE_OFFSET}/g" \
        -e "s/YOCTO_DTB_HASH_OFFSET/${DTB_HASH_OFFSET}/g" \
        -e "s/YOCTO_INITRD_FILE_OFFSET/${INITRD_FILE_OFFSET}/g" \
        -e "s/YOCTO_INITRD_HASH_OFFSET/${INITRD_HASH_OFFSET}/g" \
        -e "s/YOCTO_ROOTFS_FILE_OFFSET/${ROOTFS_FILE_OFFSET}/g" \
        -e "s/YOCTO_ROOTFS_HASH_OFFSET/${ROOTFS_HASH_OFFSET}/g" \
        -e "s/YOCTO_ROOTFSPART_SIZE/${ROOTFSPART_SIZE}/g" \
        -e "s/YOCTO_PARTITION_OFFSET/${PARTITION_OFFSET}/g" \
        -e "s/YOCTO_INFO_FILE_BLOCKS/${INFO_FILE_BLOCKS}/g" \
        -e "s/YOCTO_IMAGE_FILE_BLOCKS/${IMAGE_FILE_BLOCKS}/g" \
        -e "s/YOCTO_DTB_FILE_BLOCKS/${DTB_FILE_BLOCKS}/g" \
        -e "s/YOCTO_INITRD_FILE_BLOCKS/${INITRD_FILE_BLOCKS}/g" \
        -e "s/YOCTO_ROOTFS_FILE_BLOCKS/${ROOTFS_FILE_BLOCKS}/g" \
        -e "s/YOCTO_INFO_BYTES/${INFO_BYTES}/g" \
        -e "s/YOCTO_BLOCK_SIZE/${BLOCK_SIZE}/g" \
        -e "s/YOCTO_MAX_FILE_BLOCKS/${MAX_FILE_BLOCKS}/g" \
    -i ${WORKDIR}/git/common/main.c

    sed -e "s/YOCTO_INFO_FILE_OFFSET/${INFO_FILE_OFFSET}/g" \
        -e "s/YOCTO_INFO_HASH_OFFSET/${INFO_HASH_OFFSET}/g" \
        -e "s/YOCTO_IMAGE_FILE_OFFSET/${IMAGE_FILE_OFFSET}/g" \
        -e "s/YOCTO_IMAGE_HASH_OFFSET/${IMAGE_HASH_OFFSET}/g" \
        -e "s/YOCTO_DTB_FILE_OFFSET/${DTB_FILE_OFFSET}/g" \
        -e "s/YOCTO_DTB_HASH_OFFSET/${DTB_HASH_OFFSET}/g" \
        -e "s/YOCTO_INITRD_FILE_OFFSET/${INITRD_FILE_OFFSET}/g" \
        -e "s/YOCTO_INITRD_HASH_OFFSET/${INITRD_HASH_OFFSET}/g" \
        -e "s/YOCTO_ROOTFS_FILE_OFFSET/${ROOTFS_FILE_OFFSET}/g" \
        -e "s/YOCTO_ROOTFS_HASH_OFFSET/${ROOTFS_HASH_OFFSET}/g" \
        -e "s/YOCTO_ROOTFSPART_SIZE/${ROOTFSPART_SIZE}/g" \
        -e "s/YOCTO_PARTITION_OFFSET/${PARTITION_OFFSET}/g" \
        -e "s/YOCTO_INFO_FILE_BLOCKS/${INFO_FILE_BLOCKS}/g" \
        -e "s/YOCTO_IMAGE_FILE_BLOCKS/${IMAGE_FILE_BLOCKS}/g" \
        -e "s/YOCTO_DTB_FILE_BLOCKS/${DTB_FILE_BLOCKS}/g" \
        -e "s/YOCTO_INITRD_FILE_BLOCKS/${INITRD_FILE_BLOCKS}/g" \
        -e "s/YOCTO_ROOTFS_FILE_BLOCKS/${ROOTFS_FILE_BLOCKS}/g" \
        -e "s/YOCTO_INFO_BYTES/${INFO_BYTES}/g" \
        -e "s/YOCTO_BLOCK_SIZE/${BLOCK_SIZE}/g" \
        -e "s/YOCTO_MAX_FILE_BLOCKS/${MAX_FILE_BLOCKS}/g" \
    -i ${WORKDIR}/git/common/tmr.c


    install -m 0755 -d ${WORKDIR}/uboot_log/
    echo "INFO_FILE_BLOCKS "${INFO_FILE_BLOCKS} > ${WORKDIR}/uboot_log/replace.log
    echo "IMAGE_FILE_BLOCKS "${IMAGE_FILE_BLOCKS} >> ${WORKDIR}/uboot_log/replace.log
    echo "DTB_FILE_BLOCKS "${DTB_FILE_BLOCKS} >> ${WORKDIR}/uboot_log/replace.log
    echo "INITRD_FILE_BLOCKS "${INITRD_FILE_BLOCKS} >> ${WORKDIR}/uboot_log/replace.log
    echo "ROOTFS_FILE_BLOCKS "${ROOTFS_FILE_BLOCKS} >> ${WORKDIR}/uboot_log/replace.log

    echo "MAX_FILE_BLOCKS "${MAX_FILE_BLOCKS} >> ${WORKDIR}/uboot_log/replace.log

    echo "INFO_FILE_OFFSET "${INFO_FILE_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "INFO_HASH_OFFSET "${INFO_HASH_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "IMAGE_FILE_OFFSET "${IMAGE_FILE_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "IMAGE_HASH_OFFSET "${IMAGE_HASH_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "DTB_FILE_OFFSET "${DTB_FILE_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "DTB_HASH_OFFSET "${DTB_HASH_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "INITRD_FILE_OFFSET "${INITRD_FILE_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "INITRD_HASH_OFFSET "${INITRD_HASH_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "ROOTFS_FILE_OFFSET "${ROOTFS_FILE_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    echo "ROOTFS_HASH_OFFSET "${ROOTFS_HASH_OFFSET} >> ${WORKDIR}/uboot_log/replace.log
    
    echo "INFO_BYTES "${INFO_BYTES} >> ${WORKDIR}/uboot_log/replace.log

    echo $(ls ${WORKDIR}/git/common/main.c) >> ${WORKDIR}/uboot_log/replace.log
}