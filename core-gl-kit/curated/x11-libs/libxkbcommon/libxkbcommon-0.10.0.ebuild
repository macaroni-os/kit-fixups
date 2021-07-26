# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson multilib-minimal

DESCRIPTION="keymap handling library for toolkits and window systems"
HOMEPAGE="https://xkbcommon.org/ https://github.com/xkbcommon/libxkbcommon/"
SRC_URI="https://xkbcommon.org/download/${P}.tar.xz"
LICENSE="MIT"
KEYWORDS="*"
IUSE="X doc test"
RESTRICT="!test? ( test )"
SLOT="0"

BDEPEND="
	sys-devel/bison
	doc? ( app-doc/doxygen )"
RDEPEND="X? ( >=x11-libs/libxcb-1.10:=[xkb] )"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"

src_unpack() {
	default
	[[ $PV = 9999* ]] && git-r3_src_unpack
}

multilib_src_configure() {
	local emesonargs=(
		-Dxkb-config-root="${EPREFIX}/usr/share/X11/xkb"
		-Denable-wayland=false # Demo applications
		$(meson_use X enable-x11)
		$(meson_use doc enable-docs)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	meson_src_install
}
