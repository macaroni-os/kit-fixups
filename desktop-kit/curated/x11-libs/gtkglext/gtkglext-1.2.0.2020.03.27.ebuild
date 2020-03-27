# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools gnome2

DESCRIPTION="GL extensions for Gtk+ 2.0"
HOMEPAGE="http://gtkglext.sourceforge.net/"
SRC_URI="https://gitlab.gnome.org/api/v4/projects/3005/repository/archive?sha=ad95fbab68398f81d7a5c895276903b0695887e2 -> ${PF}.tar.gz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.34.3:2
	>=x11-libs/gtk+-2.24.23:2
	>=x11-libs/pango-1.36.3
	>=x11-libs/libX11-1.6.2
	>=x11-libs/libXmu-1.1.1-r1
	>=virtual/glu-9.0-r1
	>=virtual/opengl-7.0-r1
"
DEPEND="${RDEPEND}
	dev-util/glib-utils
	>=sys-devel/autoconf-archive-2014.02.28
	>=virtual/pkgconfig-0-r1
"

src_unpack() {
	unpack ${A}
	mv ${WORKDIR}/gtkglext-* ${WORKDIR}/${PF} || die
}

src_prepare() {
	NOCONFIGURE=1 ./autogen.sh || die
	eapply_user
}

src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--disable-static
}

src_install() {
	gnome2_src_install
	local DOCS="AUTHORS ChangeLog* NEWS README TODO"
	einstalldocs
}
