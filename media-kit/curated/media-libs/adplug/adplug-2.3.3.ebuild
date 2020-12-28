# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit out-of-source

DESCRIPTION="A free, cross-platform, hardware independent AdLib sound player library"
HOMEPAGE="http://adplug.sourceforge.net"

SRC_URI="https://github.com/adplug/${PN}/releases/download/${P}/${P}.tar.bz2"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0/${PV}"
IUSE="debug static-libs"

RDEPEND=">=dev-cpp/libbinio-1.4"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	default
}

my_src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_enable debug)
}

my_src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
