# Copyright 1999-2019 Gentoo Authors et al.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{5,6,7} )

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://github.com/mesonbuild/meson"
	inherit git-r3
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="*"
fi

inherit distutils-r1

DESCRIPTION="Open source build system"
HOMEPAGE="http://mesonbuild.com/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="vim-syntax bash-completion zsh-completion test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-util/ninja-1.5
"

DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-libs/glib:2
		dev-libs/gobject-introspection
		dev-vcs/git
		virtual/pkgconfig
	)
"
python_prepare_all() {
	# ASAN and sandbox both want control over LD_PRELOAD
	# https://bugs.gentoo.org/673016

	# test_testsetups doesn't throw CalledProcessError with --setup=valgrind

	# lcov up to 1.14 fails on gcc 9.1
	# https://github.com/linux-test-project/lcov/issues/58
	sed -e 's/test_generate_gir_with_address_sanitizer(/_&/' \
		-e 's/test_testsetups(/_&/' \
		-e 's/test_coverage(/_&/' \
		-i run_unittests.py || die

	# Remove test cases that break due to over-eager detection
	rm -r "${S}/test cases/java"
	rm -r "${S}/test cases/frameworks/17 mpi"
	rm -r "${S}/test cases/frameworks/22 gir link order"
	rm -r "${S}/test cases/frameworks/26 netcdf"

	distutils-r1_python_prepare_all
}

src_test() {
#	tc-export PKG_CONFIG
#	if ${PKG_CONFIG} --exists Qt5Core && ! ${PKG_CONFIG} --exists Qt5Gui; then
#		ewarn "Found Qt5Core but not Qt5Gui; skipping tests"
#	else
		distutils-r1_src_test
#	fi
}

python_test() {
	(
		# test_meson_installed
		unset PYTHONDONTWRITEBYTECODE

		# test_cross_file_system_paths
		unset XDG_DATA_HOME

		${EPYTHON} -u run_tests.py
	) || die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles
		doins -r data/syntax-highlighting/vim/{ftdetect,ftplugin,indent,syntax}
	fi

	if use bash-completion ; then
		insinto /usr/share/bash-completion/completions
		doins data/shell-completions/bash/meson
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins data/shell-completions/zsh/_meson
	fi
}
