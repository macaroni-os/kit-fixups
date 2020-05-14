# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

XORG_MULTILIB=yes
inherit xorg-2

DESCRIPTION="X.Org X authorization library"

KEYWORDS="*"
IUSE=""

RDEPEND="x11-base/xorg-proto"
DEPEND="${RDEPEND}"
