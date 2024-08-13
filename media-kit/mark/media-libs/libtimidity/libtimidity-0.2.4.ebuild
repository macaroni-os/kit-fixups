# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="MIDI to WAVE converter library"
HOMEPAGE="http://libtimidity.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/2"
KEYWORDS="*"
IUSE="ao debug"

RDEPEND="ao? ( >=media-libs/libao-1.1.0-r2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

RESTRICT="test"
DOCS="AUTHORS CHANGES TODO README*"

src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-static \
		$(use_enable ao) \
		$(use_enable debug)
}
