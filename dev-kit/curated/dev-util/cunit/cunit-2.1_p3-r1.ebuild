# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools eutils flag-o-matic multilib-minimal toolchain-funcs ltprune

MY_PN="CUnit"
MY_PV="${PV/_p*}-3"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="C Unit Test Framework"
SRC_URI="mirror://sourceforge/cunit/${MY_P}.tar.bz2"
HOMEPAGE="http://cunit.sourceforge.net"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="ncurses static-libs"

RDEPEND="ncurses? ( >=sys-libs/ncurses-5.9-r3:0=[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

DOCS=( AUTHORS NEWS README ChangeLog )

PATCHES=(
	"${FILESDIR}"/${PN}-2.1_p3-ncurses-format-security.patch
	"${FILESDIR}"/${PN}-ncurses.patch
)

src_prepare() {
	default

	sed -e "/^docdir/d" -i doc/Makefile.am || die
	sed -e '/^dochdrdir/{s:$(prefix)/doc/@PACKAGE@:$(docdir):}' \
		-i doc/headers/Makefile.am || die
	sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.in || die
	eautoreconf

	append-cppflags -D_BSD_SOURCE

	# unable to find headers otherwise
	multilib_copy_sources
}

multilib_src_configure() {
	local LIBS=${LIBS}
	append-libs $($(tc-getPKG_CONFIG) --libs ncurses)

	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		$(use_enable static-libs static) \
		--disable-debug \
		$(use_enable ncurses curses)
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
