# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="A terminal emulator for the Xfce desktop environment"
HOMEPAGE="https://docs.xfce.org/apps/terminal/start"
SRC_URI="https://archive.xfce.org/src/apps/${PN}/$(ver_cut 1-2)/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="utempter"

RDEPEND="
	>=dev-libs/glib-2.42:2=
	>=x11-libs/gtk+-3.22:3=
	x11-libs/libX11:=
	>=x11-libs/vte-0.51.3:2.91=
	>=xfce-base/libxfce4ui-4.16:=[gtk3(+)]
	>=xfce-base/xfconf-4.16:=
	utempter? ( sys-libs/libutempter:= )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-libs/libxml2
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog HACKING NEWS THANKS )

src_configure() {
	local myconf=(
		$(use_with utempter)
	)	econf "${myconf[@]}"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
