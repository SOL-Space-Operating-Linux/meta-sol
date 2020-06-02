SUMMARY = "SOL core development image"

LICENSE = "MIT"

#inherit core-image image_types_tegra
require core-image-sol.bb

#IMAGE_FEATURES += " tegra-dual-live-boot"

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