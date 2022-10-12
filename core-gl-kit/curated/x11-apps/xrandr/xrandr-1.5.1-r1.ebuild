# Distributed under the terms of the GNU General Public License v2

EAPI=7
XORG_TARBALL_SUFFIX="xz"

inherit xorg-3 autotools

DESCRIPTION="primitive command line interface to RandR extension"
SRC_URI="https://gitlab.freedesktop.org/xorg/app/${PN}/-/archive/${P}/${PN}-${P}.tar.bz2"
KEYWORDS="*"
IUSE=""

RDEPEND=">=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libX11"
DEPEND="${RDEPEND}
	x11-misc/util-macros
	x11-base/xorg-proto"

src_unpack() {
	xorg-3_src_unpack
	mv "${WORKDIR}/${PN}-${P}" "${WORKDIR}/${P}"
}

src_prepare() {
	eautoreconf
	xorg-3_src_prepare
}

src_install() {
	xorg-3_src_install
	rm -f "${ED}"/usr/bin/xkeystone || die
}
