EAPI=5
inherit flag-o-matic

DESCRIPTION="Pulseaudio Volume Control, GTK based mixer for Pulseaudio"
HOMEPAGE="https://freedesktop.org/software/pulseaudio/pavucontrol/"
SRC_URI="https://freedesktop.org/software/pulseaudio/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

RDEPEND="
	>=dev-libs/json-glib-1.0
	>=dev-cpp/gtkmm-3.22:3.0
	>=dev-libs/libsigc++-2.2:2
	>=media-libs/libcanberra-0.16[gtk3]
	>=media-sound/pulseaudio-3[glib]
	virtual/freedesktop-icon-theme
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? (
		dev-util/intltool
		sys-devel/gettext
	)
"

src_configure() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		--htmldir=/usr/share/doc/${PF}/html \
		--disable-lynx \
		$(use_enable nls)
}
