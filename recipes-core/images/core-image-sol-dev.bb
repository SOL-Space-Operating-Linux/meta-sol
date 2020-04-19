SUMMARY = "SOL core development image"

LICENSE = "MIT"

#inherit core-image image_types_tegra
require core-image-sol.bb

#
# Jetson Specific Configurations
#

# This must be set in your local.conf in the build/conf directory.
# NVIDIA_DEVNET_MIRROR = "file:///home/$USER$/Downloads/nvidia/sdkm_downloads"

# Development features
IMAGE_FEATURES += "ssh-server-dropbear post-install-logging \
    debug-tweaks dbg-pkgs \
"

# Packages to install
IMAGE_INSTALL += "packagegroup-core-buildessential \
    packagegroup-devtools \
"

# Set root password (password = "tegratest")
inherit extrausers
IMAGE_FEATURES_remove = "allow-empty-password empty-root-password"
EXTRA_USERS_PARAMS = "usermod -P tegratest root;"