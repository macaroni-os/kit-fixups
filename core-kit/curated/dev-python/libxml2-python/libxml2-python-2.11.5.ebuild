# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Python bindings for libxml2"

SLOT="0"
KEYWORDS="*"
IUSE="+lzma +icu"

DEPEND="=dev-libs/libxml2-${PV}:=[lzma?,icu?]"
RDEPEND="${DEPEND}"
S="${WORKDIR}"/python

src_unpack() {
	unpack ${ROOT}/usr/share/libxml2/bindings/libxml2-python-${PV}.tar.gz || die
}
