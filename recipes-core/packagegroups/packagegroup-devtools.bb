SUMMARY = "SOL development applications" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    openssh \
    openssh-sftp \
    openssh-sftp-server \
    util-linux \
    cuda-samples \
    tegra-tools \
    tegra-nvpmodel \
"