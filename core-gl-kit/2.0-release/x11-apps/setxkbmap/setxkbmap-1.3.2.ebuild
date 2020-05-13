# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit xorg-2

DESCRIPTION="Controls the keyboard layout of a running X server"

KEYWORDS="*"
IUSE=""
DEPEND="x11-libs/libxkbfile
	x11-libs/libX11"
RDEPEND="${RDEPEND}
	x11-misc/xkeyboard-config"
