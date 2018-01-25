# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="An application that queries the user for a selection for printing"
HOMEPAGE="https://github.com/naelstrof/slop"
SRC_URI="https://github.com/naelstrof/slop/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="
	dev-libs/icu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
"
DEPEND="
	${RDEPEND}
	media-libs/glew
	media-libs/glm
"
src_prepare() {
	eapply "${FILESDIR}"/${P}-cmake-install-lib64.patch
	cmake-utils_src_prepare
}	

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}	

