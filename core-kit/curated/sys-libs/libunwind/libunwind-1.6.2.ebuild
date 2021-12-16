# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}
inherit autotools

DESCRIPTION="Portable and efficient API to determine the call-chain of a program"
HOMEPAGE="https://savannah.nongnu.org/projects/libunwind"
SRC_URI="mirror://nongnu/libunwind/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0/8" # libunwind.so.8
KEYWORDS="next"
IUSE="debug debug-frame doc libatomic lzma static-libs zlib"

# We just use the header from libatomic.
RDEPEND="
	lzma? ( app-arch/xz-utils[static-libs?] )
	zlib? ( sys-libs/zlib[static-libs?] )
	!sys-libs/libunwind:7
"
DEPEND="${RDEPEND}
	libatomic? ( dev-libs/libatomic_ops )"

src_prepare() {
	default
	chmod +x src/ia64/mk_cursor_i || die
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		# --enable-cxx-exceptions: always enable it, headers provide the interface
		# and on some archs it is disabled by default causing a mismatch between the
		# API and the ABI, bug #418253
		--enable-cxx-exceptions
		--enable-coredump
		--enable-ptrace
		--enable-setjmp
		$(use_enable debug-frame)
		$(use_enable doc documentation)
		$(use_enable lzma minidebuginfo)
		$(use_enable static-libs static)
		$(use_enable zlib zlibdebuginfo)
		# conservative-checks: validate memory addresses before use; as of 1.0.1,
		# only x86_64 supports this, yet may be useful for debugging, couple it with
		# debug useflag.
		$(use_enable debug conservative_checks)
		$(use_enable debug)
		--disable-tests
	)

	export ac_cv_header_atomic_ops_h=$(usex libatomic)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name "*.la" -type f -delete || die
}
