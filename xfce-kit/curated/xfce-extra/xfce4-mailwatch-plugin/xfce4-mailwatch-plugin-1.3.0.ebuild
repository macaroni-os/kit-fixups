# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg

DESCRIPTION="An mail notification panel plug-in for the Xfce desktop environment"
HOMEPAGE="https://goodies.xfce.org/projects/panel-plugins/xfce4-mailwatch-plugin"
SRC_URI="https://archive.xfce.org/src/panel-plugins/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="ssl"

RDEPEND=">=dev-libs/glib-2.42:=
	>=x11-libs/gtk+-3.22:3=
	>=xfce-base/exo-0.11:=
	>=xfce-base/libxfce4ui-4.14:=
	>=xfce-base/libxfce4util-4.14:=
	>=xfce-base/xfce4-panel-4.14:=
	ssl? ( >=net-libs/gnutls-2:= )
"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	econf $(use_enable ssl)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
