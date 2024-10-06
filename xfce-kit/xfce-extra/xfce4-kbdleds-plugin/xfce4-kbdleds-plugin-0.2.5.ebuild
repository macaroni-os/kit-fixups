# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg

DESCRIPTION="A panel plug-in to show state of Caps, Num and Scroll Lock keys"
HOMEPAGE="https://github.com/oco2000/xfce4-kbdleds-plugin"
SRC_URI="https://github.com/oco2000/${PN}/archive/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	xfce-base/libxfce4ui:=
	xfce-base/libxfce4util:=
	xfce-base/xfce4-panel"
DEPEND=${RDEPEND}
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

S="${WORKDIR}/${PN}-${P}"

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
