# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="library for connecting and sending data to icecast servers"
HOMEPAGE="https://www.icecast.org/"
SRC_URI="http://downloads.xiph.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="speex static-libs theora"

RDEPEND="
	>=media-libs/libogg-1.3.0
	>=media-libs/libvorbis-1.3.3-r1
	dev-libs/openssl:0=
	speex? ( media-libs/speex )
	theora? ( media-libs/libtheora )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default
	# Fix docdir
	sed '/^docdir/s@$(PACKAGE)@$(PF)@' -i Makefile.am || die
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable speex)
		$(use_enable static-libs static)
		$(use_enable theora)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
