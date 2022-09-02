# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="https://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

PATCHES=(
	"${FILESDIR}"/${PN}-2.12-non-gnu-compilers.patch #275295
	"${FILESDIR}"/${PN}-2.12-gcc-10.patch #705900
	"${FILESDIR}"/${PN}-2.13-cve-2021-38185.patch
)

src_configure() {
	local myeconfargs=(
		$(use_enable nls)
		--bindir="${EPREFIX}"/bin
		--with-rmt="${EPREFIX}"/usr/sbin/rmt
	)
	econf "${myeconfargs[@]}"
}

