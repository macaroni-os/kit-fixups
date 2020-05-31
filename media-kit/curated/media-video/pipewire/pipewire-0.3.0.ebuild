# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

MY_PV="${PV%_*}"
MY_P="${PN}-${MY_PV}"

S="${WORKDIR}/${MY_P}"

RESTRICT="mirror"

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="http://pipewire.org/"
SRC_URI="https://github.com/PipeWire/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="docs examples ffmpeg gstreamer jack pulseaudio systemd"

RDEPEND="
	media-libs/alsa-lib
	media-libs/sbc
	media-video/ffmpeg:=
	jack? ( >=media-sound/jack2-1.9.10 )
	pulseaudio? ( >=media-sound/pulseaudio-11.1 )
	sys-apps/dbus
	virtual/libudev
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	systemd? ( sys-apps/systemd )
	media-libs/vulkan-loader
"
DEPEND="
	${RDEPEND}
	app-doc/xmltoman
	docs? ( app-doc/doxygen )
"

src_configure() {
	local emesonargs=(
		-Dman=true
		$(meson_use docs)
		$(meson_use examples)
		$(meson_use ffmpeg)
		$(meson_use gstreamer)
		$(meson_use jack pipewire-jack)
		$(meson_use jack)
		$(meson_use pulseaudio pipewire-pulseaudio)
		$(meson_use systemd)
	)

	meson_src_configure
}
