# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="GNU macro processor"
HOMEPAGE="https://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"
SRC_URI+=" https://dev.gentoo.org/~floppym/dist/${P}-test-198-sysval-r1.patch.gz"
KEYWORDS="*"

LICENSE="GPL-3"
SLOT="0"
IUSE="examples nls"

RDEPEND="
	virtual/libiconv
	nls? (
		sys-devel/gettext
		virtual/libintl
	)"
DEPEND="${RDEPEND}"
# Remember: cannot dep on autoconf since it needs us
BDEPEND="app-arch/xz-utils
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}"/ppc-musl.patch
	"${FILESDIR}"/loong-fix-build.patch
	"${WORKDIR}"/${P}-test-198-sysval-r1.patch
)

src_unpack() {
	default
}

src_prepare() {
	default

	# touch generated files after patching m4, to avoid activating maintainer
	# mode
	# remove when loong-fix-build.patch is no longer necessary
	touch ./aclocal.m4 ./lib/config.hin ./configure ./doc/stamp-vti || die
	find . -name Makefile.in -exec touch {} + || die
}

src_configure() {
	local -a myeconfargs=(
		--enable-changeword

		--with-packager="Gentoo Linux"
		--with-packager-version="${PVR}"
		--with-packager-bug-reports="https://bugs.gentoo.org/"

		$(usex nls '' '--disable-nls')

		# Disable automagic dependency over libsigsegv; see bug #278026
		ac_cv_libsigsegv=no
	)

	[[ ${USERLAND} != GNU ]] && myeconfargs+=( --program-prefix=g )

	econf "${myeconfargs[@]}"
}

src_test() {
	[[ -d /none ]] && die "m4 tests will fail with /none/" #244396
	emake check
}

src_install() {
	default

	# autoconf-2.60 for instance, first checks gm4, then m4.  If we don't have
	# gm4, it might find gm4 from outside the prefix on for instance Darwin
	use prefix && dosym m4 /usr/bin/gm4

	if use examples ; then
		dodoc -r examples
		rm -f "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
}
