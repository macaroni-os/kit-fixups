EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="library for decoding ATSC A/52 streams used in DVD"
HOMEPAGE="http://liba52.sourceforge.net/"
SRC_URI="http://liba52.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="djbfft"

RDEPEND="djbfft? ( >=sci-libs/djbfft-0.76-r2 )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-build.patch
	"${FILESDIR}"/${P}-freebsd.patch
	"${FILESDIR}"/${P}-tests-optional.patch
	"${FILESDIR}"/${P}-test-hidden-symbols.patch
)

src_prepare() {
	default

	sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.in || die #466978
	mv configure.{in,ac} || die

	eautoreconf

	filter-flags -fprefetch-loop-arrays
}

src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-static \
		--enable-shared \
		$(use_enable djbfft) \
		--disable-oss

}

src_compile() {
	emake CFLAGS="${CFLAGS}"
}

src_install() {
	default
	einstalldocs
	dodoc HISTORY doc/liba52.txt

	find "${ED}" -name '*.la' -type f -delete || die
}
