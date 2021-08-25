# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2+ )
PYTHON_REQ_USE="sqlite(+)"
inherit distutils-r1
DESCRIPTION="Library to extract data from HTML and XML using XPath and CSS selectors"
HOMEPAGE="https://github.com/scrapy/parsel http://pypi.python.org/pypi/parsel/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc -test"
#PATCHES=( "${FILESDIR}"/${PN}-1.1.0-remove-pytest-runner-depedency.patch )
RDEPEND="
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/w3lib-1.8.0[${PYTHON_USEDEP}]
	>=dev-python/cssselect-0.9[${PYTHON_USEDEP}]
	>=dev-python/six-1.5.2[${PYTHON_USEDEP}]
	"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
	)"
python_compile_all() {
	use doc && emake -C docs html
}
python_test() {
	py.test ${PN} tests || die "tests failed"
}
python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
