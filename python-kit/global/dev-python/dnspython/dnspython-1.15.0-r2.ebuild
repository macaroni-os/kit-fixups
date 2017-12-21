# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="DNS toolkit for Python"
HOMEPAGE="http://www.dnspython.org/ https://pypi.python.org/pypi/dnspython"
SRC_URI="https://github.com/danielrobbins/dnspython/archive/v1.15.0-cryptodome.zip"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE="examples test"

RDEPEND="dev-python/pycryptodome[${PYTHON_USEDEP}]
	!dev-python/dnspython:py2
	!dev-python/dnspython:py3"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	app-arch/unzip"

# For testsuite
DISTUTILS_IN_SOURCE_BUILD=1
S="$WORKDIR/$P-cryptodome"

python_test() {
	cd tests || die
	"${PYTHON}" utest.py || die "tests failed under ${EPYTHON}"
	einfo "Testsuite passed under ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
