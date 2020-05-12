# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="Communication package providing the X, Y, and ZMODEM file transfer protocols"
HOMEPAGE="https://www.ohse.de/uwe/software/lrzsz.html"
SRC_URI="https://www.ohse.de/uwe/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

DEPEND="nls? ( virtual/libintl )"

PATCHES=( "${FILESDIR}"/${PN}-autotools.patch
	"${FILESDIR}"/${PN}-implicit-decl.patch
	"${FILESDIR}"/${P}-automake-1.12.patch
	"${FILESDIR}"/${P}-automake-1.13.patch )

DOCS=( AUTHORS COMPATABILITY ChangeLog NEWS \
	README{,.cvs,.gettext,.isdn4linux,.tests} THANKS TODO )

src_prepare() {
	default
	# automake is unhappy if this is missing
	>> config.rpath || die
	# This is too old.  Remove it so automake puts in a newer copy.
	rm -f missing || die
	# Autoheader does not like seeing this file.
	rm -f acconfig.h || die

	mv configure.{in,ac} || die
	mv Makefile.{in,ac} || die

	sed -e 's:AM_GNU_GETTEXT::g' -i configure.ac
	sed -e 's:all-@USE_INCLUDED_LIBINTL@::g' -i Makefile.ac
	sed -e 's:all-@USE_INCLUDED_LIBINTL@::g' -i intl/Makefile.in
	sed -e 's:all-@USE_NLS@::g' -i po/Makefile.in.in
	sed -e 's:install-data-@USE_NLS@::g' -i po/Makefile.in.in
	eautoreconf
}

src_configure() {
	tc-export CC
	append-flags -Wstrict-prototypes
	econf $(use_enable nls)

	sed -e 's/@INTLLIBS@//g' -i src/Makefile
}

src_test() {
	#Don't use check target.
	#See bug #120748 before changing this function.
	make vcheck || die "tests failed"
}

src_install() {
	default

	local x
	for x in {r,s}{b,x,z} ; do
		dosym l${x} /usr/bin/${x}
		dosym l${x:0:1}z.1 /usr/share/man/man1/${x}.1
		[ "${x:1:1}" = "z" ] || dosym l${x:0:1}z.1 /usr/share/man/man1/l${x}.1
	done
}
