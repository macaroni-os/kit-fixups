# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xorg-3

DESCRIPTION="X.Org bitmap application"
SRC_URI="https://gitlab.freedesktop.org/xorg/app/${PN}/-/archive/${P}/${PN}-${P}.tar.bz2"
KEYWORDS="*"
IUSE=""
RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXaw
	x11-libs/libXt
	x11-misc/xbitmaps"
DEPEND="${RDEPEND}"

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
