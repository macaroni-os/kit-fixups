# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

MY_P="${P/sdl2-/SDL2_}"
DESCRIPTION="Graphics drawing primitives library for SDL2"
HOMEPAGE="http://www.ferzkopp.net/joomla/content/view/19/14/ https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/"
SRC_URI="http://www.ferzkopp.net/Software/SDL2_gfx/${MY_P}.tar.gz"
S="${WORKDIR}"/${MY_P}

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="media-libs/libsdl2[video]"
RDEPEND="${DEPEND}"

DOCS=( AUTHORS ChangeLog README )

src_prepare() {
	default
	mv configure.in configure.ac || die
	sed -i \
		-e 's/ -O / /' \
		configure.ac || die
	eautoreconf
}
