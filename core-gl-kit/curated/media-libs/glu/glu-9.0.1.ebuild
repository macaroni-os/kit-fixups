# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="The OpenGL Utility Library"
HOMEPAGE="https://gitlab.freedesktop.org/mesa/glu"

SRC_URI="https://mesa.freedesktop.org/archive/glu/${P}.tar.xz"
KEYWORDS="*"

LICENSE="SGI-B-2.0"
SLOT="0"
IUSE="static-libs"

DEPEND=">=virtual/opengl-7.0-r1"
RDEPEND="${DEPEND}"

src_configure() {
	ECONF_SOURCE="${S}" econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

src_test() {
	:;
}
