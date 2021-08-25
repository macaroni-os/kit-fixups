# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1 eutils

DESCRIPTION="Python code static checker"
HOMEPAGE="http://pylint.pycqa.org
    https://github.com/PyCQA/pylint/
	https://pypi.org/project/pylint/"

SRC_URI="https://files.pythonhosted.org/packages/source/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc examples test"

RDEPEND="
	>=dev-python/astroid-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/isort-4.2.5[${PYTHON_USEDEP}]
	dev-python/mccabe[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? ( ${RDEPEND}
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	)"

PATCHES=(
	"${FILESDIR}/${PN}-2.3.1-sphinx-theme.patch"
	"${FILESDIR}/${PN}-2.3.1-no-pytest-runner.patch"
)

python_compile_all() {
	# selection of straight html triggers a trivial annoying bug, we skirt it
	use doc && PYTHONPATH="${S}" emake -e -C doc singlehtml
}

python_test() {
	${EPYTHON} -m pytest -v pylint/test/ || die "tests failed"
}

python_install_all() {
	doman man/{pylint,pyreverse}.1
	if use examples ; then
		docinto examples
		dodoc -r examples/.
	fi
	use doc && local HTML_DOCS=( doc/_build/singlehtml/. )
	distutils-r1_python_install_all
}
