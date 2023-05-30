# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake gnome3-utils

DESCRIPTION="Vietnamese UniKey engine for IBus"
HOMEPAGE="https://github.com/vn-input/ibus-unikey"
SRC_URI="https://github.com/vn-input/ibus-unikey/archive/refs/tags/0.7.0-beta1.tar.gz -> ibus-unikey-0.7.0_beta1.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-i18n/ibus
	x11-libs/gtk+:3
	virtual/libintl"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/*ibus-unikey-* "${S}"
}

src_configure() {
	local mycmakeargs=(
		-DGSETTINGS_COMPILE=OFF
	)
	cmake_src_configure
}

pkg_preinst() {
	gnome3_schemas_savelist
}

pkg_postinst() {
	gnome3_schemas_update
}

pkg_postrm() {
	gnome3_schemas_update
}