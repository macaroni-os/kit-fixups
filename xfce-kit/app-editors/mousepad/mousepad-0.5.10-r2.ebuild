# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome2-utils xdg-utils

DESCRIPTION="GTK+-based editor for the Xfce Desktop Environment"
HOMEPAGE="
	https://docs.xfce.org/apps/mousepad/start
	https://gitlab.xfce.org/apps/mousepad/
"
SRC_URI="https://archive.xfce.org/src/apps/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="dbus gtk3"

RDEPEND=">=dev-libs/glib-2.52:2=
	dbus? ( >=dev-libs/dbus-glib-0.100:0= )
	gtk3? ( >=x11-libs/gtk+-3.22:3= )
	!gtk3? ( x11-libs/gtksourceview:4= )"
DEPEND="${RDEPEND}
	dev-lang/perl
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	local myconf=(
		$(use_native_use dbus)
		$(use_native_use gtk3)
		)

	econf "${myconf[@]}"
}

pkg_postinst() {
	xdg_icon_cache_update
	gnome2_schemas_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	gnome2_schemas_update
	xdg_desktop_database_update
}
