SUMMARY = "SOL core development image"
DESCRIPTION = "A development image of SOL that includes useful \
    development tools including OpenSSH, util-linux, and \
    post-install-logging."

LICENSE = "MIT"
LICENSE_FLAGS_WHITELIST = "commercial"

require core-image-sol.bb

# Development features
IMAGE_FEATURES += "splash x11-base hwcodecs ssh-server-openssh \
    post-install-logging"
IMAGE_FEATURES_remove = "allow-empty-password empty-root-password"

# Development tool packages to install
IMAGE_INSTALL += "openssh util-linux cuda-samples tegra-tools \
    tegra-nvpmodel"

# Set root password
# password = "test"
#EXTRA_USERS_PARAMS = "usermod -p m7or76bu6AEY6 root;"