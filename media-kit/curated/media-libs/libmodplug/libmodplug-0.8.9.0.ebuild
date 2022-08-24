# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Library for playing MOD-like music files"
HOMEPAGE="http://modplug-xmms.sourceforge.net/"
SRC_URI="mirror://sourceforge/modplug-xmms/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"

BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-timidity-patches.patch"
	"${FILESDIR}/${P}-no-fast-math.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --disable-static
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
}
