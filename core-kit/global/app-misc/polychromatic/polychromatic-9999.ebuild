# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4..7} )

inherit git-r3 gnome2-utils linux-mod python-single-r1

DESCRIPTION="A graphical front end for managing Razer peripherals under GNU/Linux."
HOMEPAGE="https://github.com/lah7/polychromatic"
EGIT_REPO_URI="https://github.com/lah7/polychromatic.git"
EGIT_CLONE_TYPE="shallow"
KEYWORDS=""

LICENSE="GPL-2"
SLOT="0"

RDEPEND="$PYTHON_DEPS
	app-misc/openrazer
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/setproctitle[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	x11-libs/gtk+[introspection]
	dev-libs/libappindicator:3[introspection]
	net-libs/webkit-gtk[introspection]
"
DEPEND="${RDEPEND}
	>=dev-python/lesscpy-0.11"

src_install() {
	emake LESSC=lesscpy PREFIX=/usr DESTDIR="${D}" install
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
