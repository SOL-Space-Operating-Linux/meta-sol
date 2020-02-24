SUMMARY = "MOCI core development image"

LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"

inherit core-image image_types_tegra
require core-image-moci.bb

#
# Jetson Specific Configurations
#

# This must be set in your local.conf in the build/conf directory.
# NVIDIA_DEVNET_MIRROR = "file:///home/$USER$/Downloads/nvidia/sdkm_downloads"

# Generates a .zip folder containing flashing scripts in
# tmp/deploy/images/$MACHINE$.
IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES = "tegraflash"

# Development features
IMAGE_FEATURES += "ssh-server-openssh post-install-logging \
    debug-tweaks dbg-pkgs \
"

# Packages to install
IMAGE_INSTALL = "packagegroup-core-boot packagegroup-core-buildessential \
    packagegroup-base-extended \
    packagegroup-devtools packagegroup-moci-core \
"

# Set root password (password = "tegratest")
inherit extrausers
IMAGE_FEATURES_remove = "allow-empty-password empty-root-password"
EXTRA_USERS_PARAMS = "usermod -P tegratest root;"