# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit xorg-2

DESCRIPTION="utility for modifying keymaps and pointer button mappings in X"

KEYWORDS="*"
IUSE=""

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
