# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

XORG_MULTILIB=yes
inherit xorg-2 toolchain-funcs

DESCRIPTION="X.Org X Toolkit Intrinsics library"

KEYWORDS="*"
IUSE="test"

RDEPEND="x11-base/xorg-proto
	>=x11-libs/libICE-1.0.8-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libSM-1.2.1-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	test? ( dev-libs/glib )"

src_configure() {
	tc-export_build_env
	xorg-2_src_configure
}
