# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="A fixed-point version of the Ogg Vorbis decoder (also known as libvorbisidec)"
HOMEPAGE="https://wiki.xiph.org/Tremor"
SRC_URI="https://dev.gentoo.org/~ssuominen/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="low-accuracy"

RDEPEND=">=media-libs/libogg-1.3.0:="
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-out-of-bounds-write.patch
	"${FILESDIR}"/${P}-autoconf.patch
	"${FILESDIR}"/${P}-pkgconfig.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	ECONF_SOURCE="${S}" econf $(use_enable low-accuracy)
}

src_install() {
	default
	HTML_DOCS=( doc/. )
	einstalldocs

	find "${ED}" -name '*.la' -type f -delete || die
}
