# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic libtool

DESCRIPTION="A thesaurus lib, tool and database"
HOMEPAGE="https://sourceforge.net/projects/aiksaurus"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="gtk"

RDEPEND="gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	gtk? ( virtual/pkgconfig )
"

PATCHES=(
	"${FILESDIR}/${P}-gcc43.patch"
	"${FILESDIR}/${P}-format-security.patch"
)

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	append-cppflags -std=c++11
	filter-flags -fno-exceptions
	econf $(use_with gtk)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
