# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Mesa GLw library"
HOMEPAGE="http://mesa3d.sourceforge.net/"
SRC_URI="https://archive.mesa3d.org/glw/glw-8.0.0.tar.bz2 -> glw-8.0.0.tar.bz2
"

SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
IUSE="+motif static-libs"

RDEPEND="
	!media-libs/mesa[motif]
	x11-libs/libX11
	x11-libs/libXt
	x11-libs/motif:0
	virtual/opengl"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

post_src_unpack() {
	if [ ! -d "${WORKDIR}/${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

src_configure() {
	local myeconfargs=(
		--enable-motif
		)
	econf ${myeconfargs[@]}
}