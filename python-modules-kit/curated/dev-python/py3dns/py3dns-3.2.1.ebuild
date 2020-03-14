# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6,7} pypy3 )

inherit distutils-r1

DESCRIPTION="Python DNS (Domain Name System) library"
HOMEPAGE="https://launchpad.net/py3dns"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="CNRI"
SLOT="3"
KEYWORDS="*"
IUSE="examples"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# Tests require network access
RESTRICT="test"

python_test() {
	"${EPYTHON}" -m unittest || die "tests failed with ${EPYTHON}"
}

python_install_all() {
	if use examples; then
		docinto examples
		dodoc -r tests/. tools/.
		docompress -x /usr/share/doc/${PF}/examples
	fi
	distutils-r1_python_install_all
}
