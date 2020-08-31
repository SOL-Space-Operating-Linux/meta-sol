FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://20-eth.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/20-eth.network \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/20-eth.network ${D}${sysconfdir}/systemd/network
}