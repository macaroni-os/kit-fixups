# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRC_URI="mirror://funtoo/${P}.tar.gz"
RESTRICT="mirror"
LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="pcre unicode"

DEPEND=">=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2:0=
	pcre? ( dev-libs/libpcre )"
RDEPEND="${DEPEND}"

src_prepare() {
	chmod a+x configure || die
}

src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(usex unicode)
	export ac_cv_lib_ncurses_initscr=$(usex !unicode)
	econf \
		--with-regex=$(usex pcre pcre posix) \
		--with-editor="${EPREFIX}"/usr/libexec/editor
}

src_install() {
	default

	newbin "${FILESDIR}"/lesspipe.sh lesspipe
	newenvd "${FILESDIR}"/less.envd 70less
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-483-r1" ; then
		elog "The lesspipe.sh symlink has been dropped.  If you are still setting"
		elog "LESSOPEN to that, you will need to update it to '|lesspipe %s'."
		elog "Colorization support has been dropped.  If you want that, check out"
		elog "the new app-text/lesspipe package."
	fi
}
