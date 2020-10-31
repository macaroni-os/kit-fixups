# Distributed under the terms of the GNU General Public License v2

EAPI=7

SRC_URI="https://github.com/nghttp2/nghttp2/releases/download/v${PV}/${P}.tar.xz"
KEYWORDS="*"

DESCRIPTION="HTTP/2 C Library"
HOMEPAGE="https://nghttp2.org/"

LICENSE="MIT"
SLOT="0/1.14" # <C++>.<C> SONAMEs
IUSE="cxx debug hpack-tools jemalloc libressl static-libs test +threads utils xml"

SSL_DEPEND="
	!libressl? ( >=dev-libs/openssl-1.0.2:0=[-bindist] )
	libressl? ( dev-libs/libressl:= )
"
RDEPEND="
	cxx? (
		${SSL_DEPEND}
		dev-libs/boost:=[threads]
	)
	hpack-tools? ( >=dev-libs/jansson-2.5 )
	jemalloc? ( dev-libs/jemalloc )
	utils? (
		${SSL_DEPEND}
		>=dev-libs/libev-4.15
		>=sys-libs/zlib-1.2.3
		net-dns/c-ares:=
	)
	xml? ( >=dev-libs/libxml2-2.7.7:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( >=dev-util/cunit-2.1 )"

src_configure() {
	local myeconfargs=(
		--disable-examples
		--disable-failmalloc
		--disable-python-bindings
		--disable-werror
		--without-cython
		$(use_enable cxx asio-lib)
		$(use_enable debug)
		$(use_enable hpack-tools)
		$(use_enable static-libs static)
		$(use_enable threads)
		$(use_enable utils app)
		$(use_with jemalloc)
		$(use_with xml libxml2)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default
	if ! use static-libs ; then
		find "${ED}"/usr -name '*.la' -delete || die
	fi
}
