# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs

DESCRIPTION="Convert a .rpm file to a .tar.gz archive"
HOMEPAGE="http://www.slackware.com/config/packages.php"
SRC_URI="mirror://gentoo/${P}.tar.xz
	https://dev.gentoo.org/~vapier/dist/${P}.tar.xz"

LICENSE="BSD-1"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="app-arch/cpio"

src_configure() {
	tc-export CC
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}"/usr install
	einstalldocs
}
