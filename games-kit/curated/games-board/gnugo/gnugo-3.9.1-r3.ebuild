# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="A Go-playing program"
HOMEPAGE="https://www.gnu.org/software/gnugo/devel.html"
#latest upstream version was gnugo-3.8 released February 19, 2009 
SRC_URI="mirror://gentoo/${P}.tar.gz"
##SRC_URI="https://ftp.gnu.org/gnu/gnugo/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="readline"

RDEPEND="
	readline? ( sys-libs/readline:0= )
	>=sys-libs/ncurses-5.2-r3:0=
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-3.9.1-invalid-move.patch
	"${FILESDIR}"/${PN}-3.9.1-format-security.patch

)

src_configure() {
	econf \
		$(use_with readline) \
		--enable-cache-size=32
}

src_prepare() {
	default
	append-cflags -fcommon
}
