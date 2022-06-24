DESCRIPTION = "Minimal initramfs init script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://init-boot.sh \
    file://platform-preboot.sh \
    ${@'file://platform-preboot-cboot.sh' if d.getVar('PREFERRED_PROVIDER_virtual/bootloader').startswith('cboot') else ''}"

DEPENDS += "bc-native"

COMPATIBLE_MACHINE = "(tegra)"

S = "${WORKDIR}"

do_install() {
    replace_vars

    install -m 0755 ${WORKDIR}/init-boot.sh ${D}/init
    install -m 0555 -d ${D}/proc ${D}/sys
    install -m 0755 -d ${D}/dev ${D}/mnt ${D}/run ${D}/usr
    install -m 1777 -d ${D}/tmp
    mknod -m 622 ${D}/dev/console c 5 1
    install -d ${D}${sysconfdir}
    if [ -e ${WORKDIR}/platform-preboot-cboot.sh ]; then
        cat ${WORKDIR}/platform-preboot-cboot.sh ${WORKDIR}/platform-preboot.sh > ${WORKDIR}/platform-preboot.tmp
        install -m 0644 ${WORKDIR}/platform-preboot.tmp ${D}${sysconfdir}/platform-preboot
        rm ${WORKDIR}/platform-preboot.tmp
    else
	install -m 0644 ${WORKDIR}/platform-preboot.sh ${D}${sysconfdir}/platform-preboot
    fi
}

replace_vars() {
    sed -e "s/INFO_FILE_OFFSET/${INFO_FILE_OFFSET}/g" \
        -e "s/INFO_HASH_OFFSET/${INFO_HASH_OFFSET}/g" \
        -e "s/IMAGE_FILE_OFFSET/${IMAGE_FILE_OFFSET}/g" \
        -e "s/IMAGE_HASH_OFFSET/${IMAGE_HASH_OFFSET}/g" \
        -e "s/DTB_FILE_OFFSET/${DTB_FILE_OFFSET}/g" \
        -e "s/DTB_HASH_OFFSET/${DTB_HASH_OFFSET}/g" \
        -e "s/INITRD_FILE_OFFSET/${INITRD_FILE_OFFSET}/g" \
        -e "s/INITRD_HASH_OFFSET/${INITRD_HASH_OFFSET}/g" \
        -e "s/ROOTFS_FILE_OFFSET/${ROOTFS_FILE_OFFSET}/g" \
        -e "s/ROOTFS_HASH_OFFSET/${ROOTFS_HASH_OFFSET}/g" \
        -e "s/ROOTFSPART_SIZE/${ROOTFSPART_SIZE}/g" \
        -e "s/PARTITION_OFFSET/${PARTITION_OFFSET}/g" \
        -e "s/INFO_FILE_BLOCKS/${INFO_FILE_BLOCKS}/g" \
        -e "s/IMAGE_FILE_BLOCKS/${IMAGE_FILE_BLOCKS}/g" \
        -e "s/DTB_FILE_BLOCKS/${DTB_FILE_BLOCKS}/g" \
        -e "s/INITRD_FILE_BLOCKS/${INITRD_FILE_BLOCKS}/g" \
        -e "s/ROOTFS_FILE_BLOCKS/${ROOTFS_FILE_BLOCKS}/g" \
        -e "s/INFO_BYTES/${INFO_BYTES}/g" \
        -e "s/BLOCK_SIZE/${BLOCK_SIZE}/g" \
        -e "s/MAX_FILE_BLOCKS/${MAX_FILE_BLOCKS}/g" \
        -e "s/ROOTFSPART_SIZE/${ROOTFSPART_SIZE}/g" \
        -i ${WORKDIR}/init-boot.sh
}


RDEPENDS_${PN} = "${@'util-linux-blkid' if d.getVar('PREFERRED_PROVIDER_virtual/bootloader').startswith('cboot') else ''}"
FILES_${PN} = "/"
