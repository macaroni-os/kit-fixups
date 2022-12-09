# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool

DESCRIPTION="C library for image processing and analysis"
HOMEPAGE="http://www.leptonica.org/"
SRC_URI="https://github.com/DanBloomberg/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/5"
KEYWORDS="*"
IUSE="gif jpeg jpeg2k png static-libs tiff utils webp zlib"

RDEPEND="
	gif? ( >=media-libs/giflib-5.1.3:= )
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( media-libs/openjpeg:2= )
	png? (
		media-libs/libpng:0=
		sys-libs/zlib:=
	)
	tiff? ( media-libs/tiff:0= )
	webp? ( media-libs/libwebp:= )
	zlib? ( sys-libs/zlib:= )"
DEPEND="${RDEPEND}"

DOCS=( README version-notes )

src_prepare() {
	default
	elibtoolize

	# unhtmlize docs
	local X
	for X in ${DOCS[@]}; do
		awk '/<\/pre>/{s--} {if (s) print $0} /<pre>/{s++}' \
			"${X}.html" > "${X}" || die 'awk failed'
		rm -f -- "${X}.html"
	done
}

src_configure() {
	ECONF_SOURCE="${S}" econf \
		--enable-shared \
		$(use_with gif giflib) \
		$(use_with jpeg) \
		$(use_with jpeg2k libopenjpeg) \
		$(use_with png libpng) \
		$(use_with tiff libtiff) \
		$(use_with webp libwebp) \
		$(use_with webp libwebpmux) \
		$(use_with zlib) \
		$(use_enable static-libs static) \
		$(use_enable utils programs)
}

src_install() {
	default
	einstalldocs

	# libtool archives covered by pkg-config
	find "${ED}" -name '*.la' -delete || die
}
