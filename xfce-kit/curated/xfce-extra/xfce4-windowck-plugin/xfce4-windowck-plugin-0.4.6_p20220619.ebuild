# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit autotools python-any-r1 xdg-utils

COMMIT="75d9344f7069f14b09edd72647911e029bdba757"

MY_P="${PN}-${COMMIT}"

DESCRIPTION="Xfce plugin puts the maximized window title and windows buttons on the panel"
HOMEPAGE="https://goodies.xfce.org/projects/panel-plugins/xfce4-windowck-plugin"
SRC_URI="https://gitlab.xfce.org/panel-plugins/${PN}/-/archive/${COMMIT}/${MY_P}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=x11-libs/gtk+-3.22.0:3
	x11-libs/libX11
	>=x11-libs/libwnck-3.22:3
	>=xfce-base/libxfce4ui-4.14:=
	>=xfce-base/libxfce4util-4.14:=
	>=xfce-base/xfce4-panel-4.14:=
	>=xfce-base/xfconf-4.14:="
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-util/intltool
	dev-util/xfce4-dev-tools
	media-gfx/imagemagick[png]
	sys-devel/gettext
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# run xdt-autogen from xfce4-dev-tools added as dependency by EAUTORECONF=1 to
	# rename configure.ac.in to configure.ac while grabbing $LINGUAS and $REVISION values
	NOCONFIGURE=1 xdt-autogen || die

	default
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
