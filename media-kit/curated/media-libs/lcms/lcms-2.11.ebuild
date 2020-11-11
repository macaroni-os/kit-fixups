# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool multilib-minimal

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="mirror://sourceforge/${PN}/lcms2-${PV}.tar.gz"

LICENSE="MIT"
SLOT="2"
KEYWORDS="*"
IUSE="doc jpeg static-libs test +threads tiff"

RDEPEND="
	jpeg? ( >=virtual/jpeg-0-r2:0[${MULTILIB_USEDEP}] )
	tiff? ( >=media-libs/tiff-4.0.3-r6:0=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/lcms2-${PV}"

src_prepare() {
	default
	elibtoolize  # for Prefix/Solaris
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_with jpeg)
		$(use_enable static-libs static)
		$(use_with threads)
		$(use_with tiff)
		--without-zlib
	)
	ECONF_SOURCE="${S}" \
	econf ${myeconfargs[@]}
}

multilib_src_install_all() {
	find "${ED}" -name "*.la" -delete || die

	if use doc; then
		docinto pdf
		dodoc doc/*.pdf
	fi
}
