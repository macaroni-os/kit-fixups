# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit meson xdg-utils

DESCRIPTION="The Shared MIME-info Database specification"
HOMEPAGE="https://gitlab.freedesktop.org/xdg/shared-mime-info"
SRC_URI="https://gitlab.freedesktop.org/xdg/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/glib
	dev-libs/libxml2"
DEPEND="${RDEPEND}
	app-text/xmlto
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dbuild-tools=true
		-Dupdate-mimedb=false
	)

	meson_src_configure
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}
