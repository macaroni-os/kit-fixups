# Distributed under the terms of the GNU General Public License v2

EAPI=5

NETSURF_BUILDSYSTEM=buildsystem-1.6
inherit netsurf

DESCRIPTION="decoding library for the GIF image file format, written in C"
HOMEPAGE="http://www.netsurf-browser.org/projects/libnsgif/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~m68k-mint"
IUSE=""

RDEPEND=""
DEPEND="virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc.patch
	netsurf_src_prepare
}
