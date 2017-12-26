# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 virtualx meson

DESCRIPTION="PackageKit client for the GNOME desktop"
HOMEPAGE="https://www.freedesktop.org/software/PackageKit/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="systemd udev"

RESTRICT="test"

# gdk-pixbuf used in gpk-animated-icon
# pango used on gpk-common
RDEPEND="
	>=dev-libs/glib-2.32:2
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.15.3:3
	>=x11-libs/libnotify-0.7.0:=
	x11-libs/pango

	>=app-admin/packagekit-base-0.9.1
	>=media-libs/libcanberra-0.10[gtk3]
	>=sys-apps/dbus-1.1.2

	media-libs/fontconfig
	x11-libs/libX11

	systemd? ( >=sys-apps/systemd-42 )
	!systemd? ( sys-auth/consolekit )
	udev? ( virtual/libgudev:= )
"
DEPEND="${RDEPEND}
	app-text/docbook-sgml-utils
	dev-libs/appstream-glib
	>=dev-util/gtk-doc-am-1.9
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-D enable-tests=false
		-D enable-systemd=$(usex systemd true false)
		-D enable-small-form-facto=false
	)
	meson_src_configure
}
