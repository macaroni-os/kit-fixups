# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Python bindings for libxslt"

SLOT="0"
KEYWORDS="*"
IUSE="+crypt"

DEPEND="=dev-libs/libxslt-${PV}:=[crypt?]"
RDEPEND="${DEPEND}"
S="${WORKDIR}"/python

src_unpack() {
	unpack ${ROOT}/usr/share/libxslt/bindings/libxslt-python-${PV}.tar.gz || die
}
