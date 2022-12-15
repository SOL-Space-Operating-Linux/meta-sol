
SUMMARY = "Generate simple tables in terminals from a nested list of strings."
HOMEPAGE = "https://github.com/Robpol86/terminaltables"
AUTHOR = "@Robpol86 <robpol86@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;md5=6c3eb9c9db570e8c0d4bd7b286021893"

SRC_URI = "https://files.pythonhosted.org/packages/9b/c4/4a21174f32f8a7e1104798c445dacdc1d4df86f2f26722767034e4de4bff/terminaltables-3.1.0.tar.gz"
SRC_URI[md5sum] = "863797674d8f75d22e16e6c1fdcbeb41"
SRC_URI[sha256sum] = "f3eb0eb92e3833972ac36796293ca0906e998dc3be91fbe1f8615b331b853b81"

S = "${WORKDIR}/terminaltables-3.1.0"

RDEPENDS_${PN} = ""

inherit setuptools3
