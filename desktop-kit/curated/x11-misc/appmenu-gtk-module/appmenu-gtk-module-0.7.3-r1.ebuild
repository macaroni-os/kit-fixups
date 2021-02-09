# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils gnome3-utils

DESCRIPTION="Application menu module for GTK"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu"
SRC_URI="https://gitlab.com/vala-panel-project/vala-panel-appmenu/uploads/570a2d1a65e77d42cb19e5972d0d1b84/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/glib[dbus]
	>=x11-libs/gtk+-2.24.0:2
	>=x11-libs/gtk+-3.22.0:3
"
DEPEND="${RDEPEND}
	dev-libs/wayland
"

src_prepare() {
	cmake-utils_src_prepare
	sed -i -e "/^pkg_check_modules(SYSTEMD/d" data/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DGSETTINGS_COMPILE=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_VCM=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}"/${PN} 85-${PN}
}

pkg_postinst() {
	gnome3_schemas_update
}
