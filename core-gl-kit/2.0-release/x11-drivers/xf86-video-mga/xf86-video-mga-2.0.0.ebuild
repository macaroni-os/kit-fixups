# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
XORG_DRI=dri
inherit xorg-2

DESCRIPTION="Matrox video driver"

SLOT="0"
KEYWORDS="*"

src_configure() {
	XORG_CONFIGURE_OPTIONS="$(use_enable dri)"
	xorg-2_src_configure
}
