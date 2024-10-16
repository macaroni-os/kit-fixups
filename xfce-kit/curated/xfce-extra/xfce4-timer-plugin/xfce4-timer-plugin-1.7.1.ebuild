# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg

DESCRIPTION="A simple timer plug-in for the Xfce desktop environment"
HOMEPAGE="https://goodies.xfce.org/projects/panel-plugins/xfce4-timer-plugin"
SRC_URI="https://archive.xfce.org/src/panel-plugins/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

#libx11?
RDEPEND=">=x11-libs/gtk+-3.20:3=
	>=xfce-base/libxfce4ui-4.12:=
	>=xfce-base/libxfce4util-4.12:=
	>=xfce-base/xfce4-panel-4.10:="
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig"

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
