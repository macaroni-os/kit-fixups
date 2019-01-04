# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils

DESCRIPTION="WebVfx is a video effects framework that allows video effects"
HOMEPAGE="https://www.mltframework.org/doxygen/webvfx/"
SRC_URI="https://github.com/mltframework/webvfx/releases/download/${PV}/${PN}-1.0.0.txz -> ${P}.tar.xz"

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qt3d:5
	dev-qt/qtgui:5
	dev-qt/qtopengl:5
	dev-qt/qtwebkit:5
	dev-qt/qtwidgets
	dev-qt/qtdeclarative:5
	media-libs/mlt
	"
RDEPEND="${DEPEND}"

src_configure() {
	eqmake5 PREFIX=/usr
}

src_install() {
	export INSTALL_ROOT="${D}"
	default
}
