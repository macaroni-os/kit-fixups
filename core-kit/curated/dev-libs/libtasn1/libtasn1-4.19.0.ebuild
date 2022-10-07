# Distributed under the terms of the GNU General Public License v2

EAPI=7

#VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/libtasn1.asc
#inherit multilib-minimal libtool verify-sig
inherit multilib-minimal libtool

DESCRIPTION="ASN.1 library"
HOMEPAGE="https://www.gnu.org/software/libtasn1/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"
SRC_URI+=" verify-sig? ( mirror://gnu/${PN}/${P}.tar.gz.sig )"

LICENSE="LGPL-2.1+"
SLOT="0/6" # subslot = libtasn1 soname version
KEYWORDS="*"
IUSE="static-libs test valgrind"

RESTRICT="!test? ( test )"

BDEPEND="
	sys-apps/help2man
	virtual/yacc
	test? ( valgrind? ( dev-util/valgrind ) )
"
#	verify-sig? ( sec-keys/openpgp-keys-libtasn1 )

DOCS=( AUTHORS ChangeLog NEWS README.md THANKS )

src_prepare() {
	default

	# For Solaris shared library
	elibtoolize
}

multilib_src_configure() {
	# -fanalyzer substantially slows down the build and isn't useful for
	# us. It's useful for upstream as it's static analysis, but it's not
	# useful when just getting something built.
	export gl_cv_warn_c__fanalyzer=no

	local myeconfargs=(
		$(use_enable static-libs static)
		$(multilib_native_use_enable valgrind valgrind-tests)
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	einstalldocs

	find "${ED}" -type f -name '*.la' -delete || die
}
