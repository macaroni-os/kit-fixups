# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic

MY_P="${P/_/-}"
DESCRIPTION="Tools to deal with shar archives"
HOMEPAGE="https://www.gnu.org/software/sharutils/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"
S="${WORKDIR}"/${MY_P}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

DEPEND="app-arch/xz-utils
	sys-apps/texinfo
	nls? ( >=sys-devel/gettext-0.10.35 )"

PATCHES=(
	"${FILESDIR}"/${PN}-4.15.2-glibc228.patch
	"${FILESDIR}"/${PN}-4.15.2-CVE-2018-1000097.patch
	"${FILESDIR}"/${PN}-4.15.2-gcc-10.patch
)

src_prepare() {
	default

	# Upstream is aware but thinks this isn't a bug/problem in sharutils itself
	# See http://lists.gnu.org/archive/html/bug-gnu-utils/2013-10/msg00011.html
	append-cflags $(test-flags-CC -Wno-error=format-security)
}

src_configure() {
	econf $(use_enable nls)
}
