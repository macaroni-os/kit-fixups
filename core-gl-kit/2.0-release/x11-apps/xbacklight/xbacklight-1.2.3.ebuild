# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit xorg-2

DESCRIPTION="Sets backlight level using the RandR 1.2 BACKLIGHT output property"
KEYWORDS="*"
IUSE=""

RDEPEND="x11-libs/libxcb
	>=x11-libs/xcb-util-0.3.8"
DEPEND="${RDEPEND}"
