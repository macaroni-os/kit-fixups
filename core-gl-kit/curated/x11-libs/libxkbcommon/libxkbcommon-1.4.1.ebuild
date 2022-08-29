# Distributed under the terms of the GNU General Public License v2

EAPI=7

SRC_URI="https://xkbcommon.org/download/${P}.tar.xz"
KEYWORDS="*"

PYTHON_COMPAT=( python3+ )

inherit meson ${GIT_ECLASS} python-any-r1 virtualx

DESCRIPTION="keymap handling library for toolkits and window systems"
HOMEPAGE="https://xkbcommon.org/ https://github.com/xkbcommon/libxkbcommon/"
LICENSE="MIT"
IUSE="doc static-libs test tools wayland X"
RESTRICT="!test? ( test )"
SLOT="0"

BDEPEND="
	sys-devel/bison
	doc? ( app-doc/doxygen )
	test? ( ${PYTHON_DEPS} )
	wayland? ( dev-util/wayland-scanner )
"
RDEPEND="
	X? ( >=x11-libs/libxcb-1.10[xkb] )
	wayland? ( >=dev-libs/wayland-1.2.0 )
	dev-libs/libxml2
	x11-misc/compose-tables
	app-doc/doxygen
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
"

pkg_setup() {
	if use test; then
		python-any-r1_pkg_setup
	fi
}

src_configure() {
	local emesonargs=(
		-Ddefault_library="$(usex static-libs both shared)"
		-Dxkb-config-root="${EPREFIX}/usr/share/X11/xkb"
		$(meson_use tools enable-tools)
		$(meson_use X enable-x11)
		$(meson_use doc enable-docs)
		$(meson_use wayland enable-wayland)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
