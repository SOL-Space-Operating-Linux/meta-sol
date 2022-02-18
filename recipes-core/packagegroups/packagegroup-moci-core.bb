SUMMARY = "MOCI core dependencies" 
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    ffmpeg \
    tegra-sfm \
    yolo \
    yolo-gpu \
    cudnn \
    yolo-gpu-cudnn \
    api \
    cuda-toolkit \
"
