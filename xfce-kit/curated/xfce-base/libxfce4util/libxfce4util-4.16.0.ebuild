# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit vala

DESCRIPTION="A basic utility library for the Xfce desktop environment"
HOMEPAGE="https://git.xfce.org/xfce/libxfce4util/"
SRC_URI="https://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="LGPL-2+ GPL-2+"
SLOT="0/7"
KEYWORDS="*"
IUSE="introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND=">=dev-libs/glib-2.50:=
	introspection? ( dev-libs/gobject-introspection:= )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/gtk-doc-am
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )"

src_prepare() {
	# stupid vala.eclass...
	default
}

src_configure() {
	local myconf=(
		$(use_enable introspection)
		$(use_enable vala)
	)

	use vala && vala_src_prepare
	econf "${myconf[@]}"
}

src_install() {
	default

	find "${D}" -name '*.la' -delete || die
}
