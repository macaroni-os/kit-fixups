# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
inherit distutils-r1

DESCRIPTION="SSH tunnels to remote server."
HOMEPAGE="https://pypi.org/project/sshtunnel"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

COMMON_DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

RDEPEND="${COMMON_DEPEND} dev-python/paramiko[${PYTHON_USEDEP}]"

DEPEND="${COMMON_DEPEND}
	doc? (	dev-python/docutils[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinxcontrib-napoleon[${PYTHON_USEDEP}]
		)

	test? (
		dev-python/tox[${PYTHON_USEDEP}]
	)"

python_compile_all() {
	use doc && emake -C "${S}/docs" html
}

python_install_all() {
	use doc && dohtml -r "${S}/docs/_build/html/"*
	distutils-r1_python_install_all
}

python_test() {
	esetup.py test
}
