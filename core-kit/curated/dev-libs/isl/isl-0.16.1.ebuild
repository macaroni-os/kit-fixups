# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils autotools multilib-minimal

DESCRIPTION="A library for manipulating integer points bounded by linear constraints."
HOMEPAGE="http://isl.gforge.inria.fr/"
SRC_URI="http://isl.gforge.inria.fr/${P}.tar.xz"

LICENSE="MIT"
SLOT="0/0.16"
KEYWORDS="*"
IUSE="+static-libs"

RDEPEND=">=dev-libs/gmp-5.1.3-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig"

DOCS=( ChangeLog AUTHORS README doc/isl.bib doc/manual.pdf )

src_prepare() {
	# m4/ax_create_pkgconfig_info.m4 is broken, fix it before eautoreconf
	# https://groups.google.com/group/isl-development/t/37ad876557e50f2c
	sed -e '/Libs:/s:@LDFLAGS@ ::' -i m4/ax_create_pkgconfig_info.m4 || die #382737

	# Install libisl.so.${PV}-gdb.py to gdb's autoload dir.
	sed -e '/^install-data-local:/,$ s|$(DESTDIR)$(libdir)|$(DESTDIR)$(prefix)/share/gdb/auto-load$(libdir)|g' -i Makefile.am

	eapply_user
	eautoreconf
}

multilib_src_configure() {
	# TODO: Add option to support option: --with-gcc-arch=<arch>  use architecture <arch> for gcc -march/-mtune, instead of guessing
	ECONF_SOURCE="${S}" econf $(use_enable static-libs static)
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
