# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="Python bindings for libgit2"
HOMEPAGE="https://github.com/libgit2/pygit2 https://pypi.org/project/pygit2/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="
	!test? ( test )
	 network-sandbox
"

RDEPEND="
	>=dev-libs/libgit2-1.0.0
	dev-python/cached-property[${PYTHON_USEDEP}]
	>=dev-python/cffi-1.0:=[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )"

src_prepare() {
	distutils-r1_src_prepare
	# we need to move test folder to prevent pytest from forcing '..' for imports
	mkdir pkg_testing_folder || die
	mv test pkg_testing_folder/ || die
	ln -s pkg_testing_folder/test test || die
}

python_test() {
	# test library can be imported
	cd ${BUILD_DIR}
	python -c "import ${PN}" || die "import statement failed"
	# execute pytest on sources
	cd ${S}
	pytest -vv || die
}
