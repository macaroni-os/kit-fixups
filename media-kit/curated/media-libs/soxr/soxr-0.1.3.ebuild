# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_P="${P}-Source"
DESCRIPTION="SoX Resampler library"
HOMEPAGE="https://sourceforge.net/p/soxr/wiki/Home/"
SRC_URI="mirror://sourceforge/soxr/${MY_P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="examples test"

# CMakeLists.txt builds examples if either test or examples USE flag is enabled.
REQUIRED_USE="test? ( examples )"
RESTRICT="!test? ( test )"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/${PN}-0.1.1-nodoc.patch"
	"${FILESDIR}/${P}-fix-pkgconfig.patch"
)

src_configure() {
	local mycmakeargs=(
		-Wno-dev
		-DBUILD_EXAMPLES="$(usex examples)"
		-DBUILD_TESTS="$(usex test)"
	)
	if use examples ; then
		mycmakeargs+=(
			-DDOC_INSTALL_DIR="/usr/share/doc/${PF}"
		)
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install
	if use examples ; then
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
