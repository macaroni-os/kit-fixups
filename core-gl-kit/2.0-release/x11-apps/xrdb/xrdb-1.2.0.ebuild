# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit xorg-2

DESCRIPTION="X server resource database utility"
KEYWORDS="*"
IUSE=""

RDEPEND="x11-libs/libXmu
	x11-libs/libX11"
DEPEND="${RDEPEND}"
