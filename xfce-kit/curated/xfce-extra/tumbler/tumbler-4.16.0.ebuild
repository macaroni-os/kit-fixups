# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="A thumbnail service for Thunar"
HOMEPAGE="https://docs.xfce.org/xfce/thunar/start"
SRC_URI="https://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="curl epub ffmpeg gstreamer jpeg odf pdf raw"

COMMON_DEPEND=">=dev-libs/glib-2.50:2
	media-libs/freetype:2=
	media-libs/libpng:0=
	>=sys-apps/dbus-1.6
	>=x11-libs/gdk-pixbuf-2.14:2
	curl? ( >=net-misc/curl-7.25:= )
	epub? ( app-text/libgepub )
	ffmpeg? ( >=media-video/ffmpegthumbnailer-2.0.8:= )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		)
	jpeg? ( virtual/jpeg:0= )
	odf? ( >=gnome-extra/libgsf-1.14.20:= )
	pdf? ( >=app-text/poppler-0.12.4[cairo] )
	raw? ( >=media-libs/libopenraw-0.0.8:=[gtk] )"
RDEPEND="${COMMON_DEPEND}
	>=xfce-base/thunar-1.4
	gstreamer? ( media-plugins/gst-plugins-meta:1.0 )"
DEPEND="${COMMON_DEPEND}
	dev-util/gdbus-codegen
	dev-util/gtk-doc-am
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	local myconf=(
		$(use_enable curl cover-thumbnailer)
		$(use_enable epub gepub-thumbnailer)
		$(use_enable jpeg jpeg-thumbnailer)
		$(use_enable ffmpeg ffmpeg-thumbnailer)
		$(use_enable gstreamer gstreamer-thumbnailer)
		$(use_enable odf odf-thumbnailer)
		$(use_enable pdf poppler-thumbnailer)
		$(use_enable raw raw-thumbnailer)
	)

	econf "${myconf[@]}"
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
