SUMMARY = "First SOL core image"


LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"


#Jetson hardcoding

CUDA_VERSION="10.0"
NVIDIA_DEVNET_MIRROR = "file:///home/aplsim/Downloads/nvidia/sdkm_downloads"

#IMAGE_FEATURES_append = " splash x11-base hwcodecs ssh-server-openssh post-install-logging"
#IMAGE_FEATURES_remove = "allow-empty-password"
#IMAGE_FEATURES_remove = "empty-root-password"



#inherit core-image extrausers

# Here, we set the root password for the image
# password = test
#EXTRA_USERS_PARAMS = "usermod -p m7or76bu6AEY6 root;"

IMAGE_CLASSES += "image_types_tegra"

IMAGE_FSTYPES = "tegraflash"

PREFERRED_PROVIDER_virtual/bootloader = "cboot-prebuilt"




GCCVERSION = "linaro-7.%"
# GCC 7 doesn't support fmacro-prefix-map, results in "error: cannot compute suffix of object files: cannot compile"
# Change the value from bitbake.conf DEBUG_PREFIX_MAP to remove -fmacro-prefix-map
DEBUG_PREFIX_MAP = "-fdebug-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
                    -fdebug-prefix-map=${STAGING_DIR_HOST}= \
                    -fdebug-prefix-map=${STAGING_DIR_NATIVE}= \
                    "

#Tegra specific
IMAGE_INSTALL_append = " cuda-samples \
    tegra-tools \
    tegra-nvpmodel \
    "
#Development specific
IMAGE_INSTALL_append = " openssh util-linux"

IMAGE_INSTALL = "\
    sudo nano \
    "