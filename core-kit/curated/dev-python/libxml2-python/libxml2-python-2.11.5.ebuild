# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE=""

DEPEND="=dev-libs/libxml2-2.11.5:=[lzma?,icu?]"
RDEPEND="${DEPEND}"
IUSE="+icu +lzma"
SLOT="0"
LICENSE=""
KEYWORDS="*"

S="$WORKDIR"/python

src_unpack() {
	unpack ${ROOT}/usr/share/libxml2/bindings/libxml2-python-${PV}.tar.gz || die
}
