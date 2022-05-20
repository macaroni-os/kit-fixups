# Distributed under the terms of the GNU General Public License v2

EAPI=7

KEYWORDS="*"

SRC_URI="https://github.com/atlas-engineer/nyxt/releases/download/${PV}/nyxt-${PV}-source-with-submodules.tar.xz -> ${P}.tar.xz"
DESCRIPTION="Nyxt - the internet on your terms."
HOMEPAGE="https://nyxt.atlas.engineer/"
LICENSE="BSD CC-BY-SA-3.0"
SLOT="0"
IUSE="X spell"

DEPEND="net-libs/webkit-gtk
	dev-libs/gobject-introspection
	net-libs/glib-networking
	gnome-base/gsettings-desktop-schemas
	sys-libs/libfixposix
	X? ( x11-misc/xclip )
	spell? ( app-text/enchant )"
BDEPEND=">=dev-lisp/sbcl-2.0.0"
RESTRICT="primaryuri"
S="${WORKDIR}"

src_compile(){
	env PREFIX=/usr emake all || die emake failed
}

src_install() {
	env PREFIX=/usr DESTDIR="${D}" emake install
	einstalldocs
}
