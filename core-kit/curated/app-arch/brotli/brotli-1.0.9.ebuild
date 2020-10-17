# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} pypy )
DISTUTILS_OPTIONAL="1"
DISTUTILS_IN_SOURCE_BUILD="1"

inherit cmake-multilib distutils-r1

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"

SLOT="0/$(ver_cut 1)"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"

IUSE="python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

LICENSE="MIT python? ( Apache-2.0 )"

DOCS=( README.md CONTRIBUTING.md )

KEYWORDS="*"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

PATCHES=(
	"${FILESDIR}/${PV}-linker.patch"
)


src_prepare() {
	use python && distutils-r1_src_prepare
	cmake-utils_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
	)
	cmake-utils_src_configure
}
src_configure() {
	cmake-multilib_src_configure
	use python && distutils-r1_src_configure
}

multilib_src_compile() {
	cmake-utils_src_compile
}
src_compile() {
	cmake-multilib_src_compile
	use python && distutils-r1_src_compile
}

python_test(){
	esetup.py test || die
}

multilib_src_test() {
	cmake-utils_src_test
}
src_test() {
	cmake-multilib_src_test
	use python && distutils-r1_src_test
}

multilib_src_install() {
	cmake-utils_src_install
}
multilib_src_install_all() {
	use python && distutils-r1_src_install
}
