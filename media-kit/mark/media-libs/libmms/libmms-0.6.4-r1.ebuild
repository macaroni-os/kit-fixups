# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Library for accessing Microsoft Media Server (MMS) media streaming protocol"
HOMEPAGE="https://sourceforge.net/projects/libmms/ https://launchpad.net/libmms/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

BDEPEND="virtual/pkgconfig"

src_configure() {
	ECONF_SOURCE=${S} econf --disable-static
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
