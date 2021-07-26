# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit xorg-2

DESCRIPTION="list interned atoms defined on server"
KEYWORDS="*"
IUSE=""

RDEPEND="x11-libs/libxcb"
DEPEND="${RDEPEND}"
