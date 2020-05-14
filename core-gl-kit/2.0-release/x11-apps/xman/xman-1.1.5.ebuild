# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
XORG_EAUTORECONF=yes
inherit xorg-2

DESCRIPTION="Manual page display program for the X Window System"

KEYWORDS="*"
IUSE=""

DEPEND="x11-libs/libXaw
	x11-libs/libXt
	x11-libs/libXmu"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.1.3-mandb-2.7.patch
)
