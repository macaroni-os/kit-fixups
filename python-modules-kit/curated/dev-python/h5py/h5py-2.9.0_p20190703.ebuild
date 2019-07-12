# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6,7} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Simple Python interface to HDF5 files"
HOMEPAGE="http://www.h5py.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc test examples mpi"

GITHUB_REPO="$PN"
GITHUB_USER="h5py"
GITHUB_TAG="596748d"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

RDEPEND="
	sci-libs/hdf5:=[mpi=,hl(+)]
	>=dev-python/numpy-1.17.0_rc1[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]"

DEPEND="
	${RDEPEND}
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/pkgconfig[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? (
		dev-python/alabaster[${PYTHON_USEDEP}]
		>=dev-python/sphinx-1.3.1[${PYTHON_USEDEP}]
		)
	mpi? ( dev-python/mpi4py[${PYTHON_USEDEP}] )"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

pkg_setup() {
	use mpi && export CC=mpicc
}

python_prepare_all() {
	append-cflags -fno-strict-aliasing
	distutils-r1_python_prepare_all
}

python_configure() {
	esetup.py configure $(usex mpi --mpi '')
}

python_compile_all() {
	if use doc; then
		cd "${S}"/docs || die
		sed '/html_theme/s:default:alabaster:g' -i conf.py || die
		emake html
	fi
}

python_test() {
	esetup.py test
}

python_install_all() {
	DOCS=( README.rst ANN.rst )
	use doc && HTML_DOCS=( docs/_build/html/. )
	use examples && DOCS+=( examples )

	distutils-r1_python_install_all
}
