# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2+ )

inherit distutils-r1

DESCRIPTION="Python interface to Graphviz's Dot language"
HOMEPAGE="https://github.com/erocarrera/pydot https://pypi.python.org/pypi/pydot"
# pypi releases don't include tests
SRC_URI="https://github.com/erocarrera/pydot/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	dev-python/pyparsing[${PYTHON_USEDEP}]
	media-gfx/graphviz
	!media-gfx/pydot"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/chardet[${PYTHON_USEDEP}] )"

python_test() {
	cd test || die
	"${PYTHON}" pydot_unittest.py || die "Test failed with ${EPYTHON}"
}
