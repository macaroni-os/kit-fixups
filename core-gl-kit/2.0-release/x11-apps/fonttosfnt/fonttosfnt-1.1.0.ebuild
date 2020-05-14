# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit xorg-2

DESCRIPTION="X.Org fonttosfnt application"
SRC_URI="https://gitlab.freedesktop.org/xorg/app/${PN}/-/archive/${P}/${PN}-${P}.tar.bz2"
KEYWORDS="*"
IUSE=""
RDEPEND="x11-libs/libX11
	=media-libs/freetype-2*
	x11-libs/libfontenc"
DEPEND="${RDEPEND}"
