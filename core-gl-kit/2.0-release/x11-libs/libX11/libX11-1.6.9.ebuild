# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

XORG_DOC=doc
XORG_EAUTORECONF=yes
XORG_MULTILIB=yes
inherit xorg-3 toolchain-funcs

DESCRIPTION="X.Org X11 library"

KEYWORDS="*"
IUSE="ipv6 test"

RDEPEND=">=x11-libs/libxcb-1.11.1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	x11-base/xorg-proto
	x11-libs/xtrans"
BDEPEND="test? ( dev-lang/perl )"

pkg_setup() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_with doc xmlto)
		$(use_enable doc specs)
		$(use_enable ipv6)
		--without-fop
	)
}
