# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Hand write recognition/input for IBus"
HOMEPAGE="https://github.com/microcai/ibus-handwrite"
SRC_URI="https://github.com/microcai/ibus-handwrite/tarball/30e5d656a0b26f62869cde2422e9b47d1e550e2d -> ibus-handwrite-3.0-30e5d65.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="nls +zinnia"

RDEPEND="app-i18n/ibus
	x11-libs/gtk+:3
	x11-libs/gtkglext
	nls? ( virtual/libintl )
	zinnia? (
		app-i18n/zinnia
		app-i18n/zinnia-tomoe
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

PATCHES=( "${FILESDIR}"/${PN}-headers.patch )

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/microcai-ibus-handwrite*/ "${S}"
}

src_configure() {
	./autogen.sh
	econf \
		$(use_enable nls) \
		$(use_enable zinnia) \
		$(use_with zinnia zinnia-tomoe "${EPREFIX}"/usr/$(get_libdir)/zinnia/model/tomoe)
}
