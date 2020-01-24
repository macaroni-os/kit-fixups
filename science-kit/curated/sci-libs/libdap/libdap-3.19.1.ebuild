# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="Implementation of libdap C++ SDK with DAP2 and DAP4 support"
HOMEPAGE="http://opendap.org/"
SRC_URI="https://github.com/OPENDAP/libdap4/archive/version-${PV}.tar.gz  -> ${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 URI )"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="static-libs test allow-network-tests"

RDEPEND="
	net-libs/libtirpc
	net-libs/rpcsvc-proto
	>=dev-libs/libxml2-2.7.0:2
	>=net-misc/curl-7.19.0
	sys-libs/zlib"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-devel/flex-2.5.35
	test? ( dev-util/cppunit )"

PATCHES=(
	"${FILESDIR}/${PN}-3.18.1-fix-c++14.patch"
	"${FILESDIR}/${PN}-3.19.1-use-libtirpc.patch"
)

S="${WORKDIR}/libdap4-version-${PV}"

src_prepare() {

	default
	# Fixup tests for easier sedding
	sed -re '/check_SCRIPTS/ {
				N
				s/(check_SCRIPTS.*)\\\n\t(.*)/\1\2/
			}' \
		-i tests/Makefile.am || die

	# Don't install test libs and headers in system
	sed -e 's/^lib_LIBRARIES = /noinst_LIBRARIES = /' \
		-e 's/^testheaders_HEADERS = /noinst_testheaders = /' \
		-i tests/Makefile.am || die

	# Remove network tests unless requested
	if ! use allow-network-tests ; then
		sed -e '/UNIT_TESTS = /,/UNIT_TESTS += / {
					s/HTTPConnectTest// ;
					s/RCReaderTest// ;
					s/HTTPCacheTest//
				}' \
			-i unit-tests/Makefile.am || die

		sed -e '/^.*$(SHELL).*$(GETDAPTESTSUITE).*/d' \
			-e 's/$(GETDAPTESTSUITE)//g' \
			-i tests/Makefile.am || die
	fi

	# Disable tests which break on big-endian machines if we're not little-endian.
	if [ "$(tc-endian)" != "little" ] ; then 
		sed -e '/^\t$(SHELL)'"'"'$(DMRTESTSUITE)/d' \
			-e 's/$(DMRTESTSUITE)//g' \
			-i tests/Makefile.am || die
	fi

	# Fix CFLAGS to use libtirpc using the brute-force method.
	sed -e 's/$(XML2_CFLAGS)/& $(TIRPC_CFLAGS)/' \
		-e 's/$(CURL_CFLAGS)/& $(TIRPC_CFLAGS)/' \
		-e 's/$(AM_CPPFLAGS)/& $(TIRPC_CFLAGS)/' \
		-i Makefile.am */Makefile.am */*/Makefile.am || die

	# Fix dap-config.in to include tirpc cflags as needed.
	sed -e 's|@CURL_CFLAGS@|& @TIRPC_CFLAGS@|' -i dap-config.in || die

	# Fix .pc.in files to include tirpc cflags and libs as needed.
	sed -e 's|^Cflags:.*|& @TIRPC_CFLAGS@|' \
		-e 's|^Libs:.*|& @TIRPC_LIBS@|' \
		-i *.pc.in || die

	eautoreconf
}

src_configure() {
	# bug 619144
	append-cxxflags -std=c++14
	econf \
		--enable-shared \
		$(use_enable static-libs static)
		#$(use_with libtirpc)
}

src_install() {
	default

	# package provides .pc files
	find "${D}" -name '*.la' -delete || die
}
