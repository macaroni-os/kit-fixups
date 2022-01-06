# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools xdg-utils

DESCRIPTION="LightDM GTK+ Greeter"
HOMEPAGE="https://github.com/Xubuntu/lightdm-gtk-greeter"
SRC_URI="https://github.com/Xubuntu/${PN}/releases/download/${P}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="appindicator"

DEPEND="appindicator? ( dev-libs/libindicator:3 )
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2"

BDEPEND="
	dev-util/intltool
	dev-util/xfce4-dev-tools
	sys-devel/gettext
"

RDEPEND="${DEPEND}
	x11-themes/gnome-themes-standard
	>=x11-themes/adwaita-icon-theme-3.14.1"


src_prepare() {
	default

	# Fix docdir
	sed "/^docdir/s@${PN}@${PF}@" -i data/Makefile.am || die
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-kill-on-sigterm
		--enable-at-spi-command="${EPREFIX}/usr/libexec/at-spi-bus-launcher --launch-immediately"
		$(use_enable appindicator libindicator)
	)
	econf "${myeconfargs[@]}"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
