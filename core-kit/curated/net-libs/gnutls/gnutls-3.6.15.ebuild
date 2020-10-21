# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool

DESCRIPTION="A TLS 1.2 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="mirror://gnupg/gnutls/v$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="GPL-3 LGPL-2.1+"
SLOT="0/30" # libgnutls.so number
KEYWORDS="*"
IUSE="+cxx dane doc examples guile +idn nls +openssl +pkcs11 seccomp sslv2 sslv3 static-libs test test-full +tls-heartbeat tools valgrind"

REQUIRED_USE="
	test-full? ( cxx dane doc examples guile idn nls openssl pkcs11 seccomp tls-heartbeat tools )"
RESTRICT="!test? ( test )"

# NOTICE: sys-devel/autogen is required at runtime as we
# use system libopts
RDEPEND=">=dev-libs/libtasn1-4.9:=
	dev-libs/libunistring:=
	>=dev-libs/nettle-3.4.1:=[gmp]
	>=dev-libs/gmp-5.1.3-r1:=
	tools? ( sys-devel/autogen:= )
	dane? ( >=net-dns/unbound-1.4.20:= )
	guile? ( >=dev-scheme/guile-2:=[networking] )
	nls? ( >=virtual/libintl-0-r1:= )
	pkcs11? ( >=app-crypt/p11-kit-0.23.1:= )
	idn? ( >=net-dns/libidn2-0.16-r1:= )"
DEPEND="${RDEPEND}
	test? (
		seccomp? ( sys-libs/libseccomp )
	)"
BDEPEND=">=virtual/pkgconfig-0-r1
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )
	tools? ( sys-devel/autogen )
	valgrind? ( dev-util/valgrind )
	test-full? (
		app-crypt/dieharder
		>=app-misc/datefudge-1.22
		dev-libs/softhsm:2[-bindist]
		net-dialup/ppp
		net-misc/socat
	)"

DOCS=(
	README.md
	doc/certtool.cfg
)

HTML_DOCS=()

pkg_setup() {
	# bug#520818
	export TZ=UTC

	use doc && HTML_DOCS+=(
		doc/gnutls.html
	)
}

src_prepare() {
	default

	# force regeneration of autogen-ed files
	local file
	for file in $(grep -l AutoGen-ed src/*.c) ; do
		rm src/$(basename ${file} .c).{c,h} || die
	done

	# Use sane .so versioning on FreeBSD.
	elibtoolize
}

src_configure() {
	LINGUAS="${LINGUAS//en/en@boldquot en@quot}"

	local libconf=()

	# TPM needs to be tested before being enabled
	libconf+=( --without-tpm )

	# hardware-accell is disabled on OSX because the asm files force
	#   GNU-stack (as doesn't support that) and when that's removed ld
	#   complains about duplicate symbols
	[[ ${CHOST} == *-darwin* ]] && libconf+=( --disable-hardware-acceleration )

	# Cygwin as does not understand these asm files at all
	[[ ${CHOST} == *-cygwin* ]] && libconf+=( --disable-hardware-acceleration )

	local myeconfargs=(
		$(enable manpages)
		$(use_enable doc gtk-doc)
		$(use_enable doc)
		$(use_enable guile)
		$(use_enable seccomp seccomp-tests)
		$(use_enable test tests)
		$(use_enable test-full full-test-suite)
		$(use_enable tools)
		$(use_enable valgrind valgrind-tests)
		$(use_enable cxx)
		$(use_enable dane libdane)
		$(use_enable nls)
		$(use_enable openssl openssl-compatibility)
		$(use_enable sslv2 ssl2-support)
		$(use_enable sslv3 ssl3-support)
		$(use_enable static-libs static)
		$(use_enable tls-heartbeat heartbeat-support)
		$(use_with idn)
		$(use_with pkcs11 p11-kit)
		--disable-rpath
		--with-default-trust-store-file="${EPREFIX}/etc/ssl/certs/ca-certificates.crt"
		--with-unbound-root-key-file="${EPREFIX}/etc/dnssec/root-anchors.txt"
		--without-included-libtasn1
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
	)
	ECONF_SOURCE="${S}" econf "${libconf[@]}" "${myeconfargs[@]}"
}

src_install() {
	default
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die

	if use examples; then
		docinto examples
		dodoc doc/examples/*.c
	fi
}
