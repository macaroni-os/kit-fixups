# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools libtool toolchain-funcs prefix

DESCRIPTION="Contains error handling functions used by GnuPG software"
HOMEPAGE="https://www.gnupg.org/related_software/libgpg-error"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="common-lisp nls static-libs"

RDEPEND="nls? ( >=virtual/libintl-0-r1 )"
DEPEND="${RDEPEND}"
BDEPEND="nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}/${PN}-1.37-remove_broken_check.patch"
)

src_configure() {
	local myeconfargs=(
		$(use_enable common-lisp languages)
		$(use_enable nls)
		# required for sys-power/suspend[crypt], bug 751568
		$(use_enable static-libs static)
		--enable-threads
		CC_FOR_BUILD="$(tc-getBUILD_CC)"
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
}
