# Copyright 1999-2018 Gentoo Foundation
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

IUSE="docs gstreamer systemd"

RDEPEND="
	media-libs/alsa-lib
	media-libs/sbc
	media-video/ffmpeg:=
	sys-apps/dbus
	virtual/libudev
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	systemd? ( sys-apps/systemd )
"
DEPEND="
	${RDEPEND}
	app-doc/xmltoman
	docs? ( app-doc/doxygen )
"

src_configure() {
	local emesonargs=(
		-Dgstreamer=$(usex gstreamer enabled disabled)
		-Dman=true
		$(meson_use docs)
		$(meson_use systemd)
	)
	meson_src_configure
}
