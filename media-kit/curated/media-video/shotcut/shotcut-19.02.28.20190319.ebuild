# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2 qmake-utils xdg-utils

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="https://www.shotcut.org/"
SRC_URI="https://github.com/mltframework/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="*"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgraphicaleffects:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtprintsupport:5
	dev-qt/qtquickcontrols:5[widgets]
	dev-qt/qtsql:5
	dev-qt/qtwebkit:5
	dev-qt/qtwebsockets:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	dev-qt/qtx11extras:5
	media-libs/ladspa-sdk
	media-libs/libsdl:0
	media-libs/libvpx
	>=media-libs/mlt-6.12.0.20190319[ffmpeg,frei0r,fftw,vidstab,jack,qt5,sdl,sdl1,xml]
	media-libs/x264
	>=media-plugins/frei0r-plugins-1.6.1.20190222
	>=media-plugins/swh-plugins-0.4.17.20190319
	media-plugins/webvfx
	media-sound/lame
	media-video/ffmpeg[jack,frei0r,ladspa,sdl]
	media-video/movit
	virtual/jack
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
"

GITHUB_REPO="shotcut"
GITHUB_USER="mltframework"
GITHUB_TAG="960c655"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

src_prepare() {
	local mylrelease="$(qt5_get_bindir)/lrelease"
	"${mylrelease}" "${S}/src/src.pro" || die "preparing locales failed"
	default
}

src_configure() {
	eqmake5 PREFIX="${EPREFIX}/usr" SHOTCUT_VERSION="${PV}"
}

src_install() {
	emake INSTALL_ROOT="${D}" install

	newicon "${S}/icons/shotcut-logo-64.png" "${PN}.png"
	make_desktop_entry shotcut "Shotcut"

	einstalldocs
}

pkg_postinst(){
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm(){
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
