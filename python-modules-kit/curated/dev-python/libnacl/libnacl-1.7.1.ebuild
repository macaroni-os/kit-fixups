# Copyright 2020 Funtoo Solutions, Inc.

EAPI=6
PYTHON_COMPAT=( python2+ )
inherit distutils-r1

DESCRIPTION="Python ctypes wrapper for libsodium"
HOMEPAGE="https://libnacl.readthedocs.org/"
SRC_URI="https://github.com/saltstack/libnacl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-libs/libsodium"

python_test() {
	${EPYTHON} tests/runtests.py || die
}
