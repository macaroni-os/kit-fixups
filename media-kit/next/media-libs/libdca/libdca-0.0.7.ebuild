EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="Library for decoding DTS Coherent Acoustics streams used in DVD"
HOMEPAGE="https://www.videolan.org/developers/libdca.html"
SRC_URI="https://www.videolan.org/pub/videolan/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

DOCS=( AUTHORS ChangeLog NEWS README TODO doc/${PN}.txt )

PATCHES=(
	"${FILESDIR}"/${PN}-0.0.5-cflags.patch
	"${FILESDIR}"/${PN}-0.0.5-tests-optional.patch
	"${FILESDIR}"/${PN}-0.0.7-slibtool.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-lfs-flags #328875

	local myeconfargs=(
		--disable-static
		--disable-oss
		$(use_enable debug)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

	# Those are thrown away afterwards, don't build them in the first place
	if [[ "${ABI}" != "${DEFAULT_ABI}" ]] ; then
		sed -e 's/ libao src//' -i Makefile || die
	fi
}

src_compile() {
	emake OPT_CFLAGS=""
}

src_install() {
	emake DESTDIR="${D}" install

	find "${D}" -name '*.la' -type f -delete || die
	rm "${D}"/usr/$(get_libdir)/libdts.a || die
}
