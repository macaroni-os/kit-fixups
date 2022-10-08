# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_REMOVE_MODULES_LIST=( FindFreetype )
PYTHON_COMPAT=( python3+ )

inherit cmake-utils python-single-r1 xdg-utils

# 0 - obs-studio.tar.gz

SRC_URI="
	https://api.github.com/repos/obsproject/obs-studio/tarball/28.0.3 -> obs-studio-28.0.3.tar.gz
	https://github.com/obsproject/obs-amd-encoder/archive/5a1dafeddb4b37ca2ba2415cf88b40bff8aee428.tar.gz -> obs-amd-encoder-2.5.2.tar.gz
	https://github.com/obsproject/obs-browser/archive/b6e0888084ab623f0a73e8cb7ee5dc341e56fda1.tar.gz -> obs-browser.tar.gz
	https://github.com/obsproject/obs-websocket/archive/5716577019b1ccda01a12db2cba35a023082b7ad.tar.gz -> obs-websocket-5.0.1.tar.gz
	https://github.com/zaphoyd/websocketpp/archive/56123c87598f8b1dd471be83ca841ceae07f95ba.tar.gz -> websocketpp-0.8.2.tar.gz
	https://github.com/nayuki/QR-Code-generator/archive/8518684c0f33d004fa93971be2c6a8eca3167d1e.tar.gz -> QR-Code-generator-1.8.0.tar.gz
	https://github.com/nlohmann/json/archive/a34e011e24beece3b69397a03fdc650546f052c3.tar.gz -> nlohmann-json.3.9.1.tar.gz
	https://github.com/chriskohlhoff/asio/archive/b73dc1d2c0ecb9452a87c26544d7f71e24342df6.tar.gz -> asio-1.12.1.tar.gz
	https://cdn-fastly.obsproject.com/downloads/cef_binary_5060_linux64.tar.bz2
	"

KEYWORDS="*"

DESCRIPTION="Software for Recording and Streaming Live Video Content"
HOMEPAGE="https://obsproject.com"

LICENSE="GPL-2"
SLOT="0"
IUSE="+alsa browser fdk ftl jack luajit nvenc pipewire pulseaudio python speex +ssl truetype v4l vlc wayland"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

BDEPEND="
	luajit? (
		dev-lua/luajit
		dev-lang/swig
	)
	python? ( dev-lang/swig )
"
DEPEND="
	>=dev-libs/jansson-2.5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtsql:5
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	media-libs/x264
	media-video/ffmpeg:=[x264]
	net-misc/curl
	sys-apps/dbus
	sys-libs/zlib
	virtual/udev
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXfixes
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libxcb
	alsa? ( media-libs/alsa-lib )
	fdk? ( media-libs/fdk-aac:= )
	jack? ( virtual/jack )
	luajit? ( dev-lang/luajit:2 )
	nvenc? (
		|| (
			<media-video/ffmpeg-4[nvenc]
			>=media-video/ffmpeg-4[video_cards_nvidia]
		)
	)
	pipewire? ( media-video/pipewire )
	pulseaudio? ( media-sound/pulseaudio )
	python? ( ${PYTHON_DEPS} )
	speex? ( media-libs/speexdsp )
	ssl? ( net-libs/mbedtls:= )
	truetype? (
		media-libs/fontconfig
		media-libs/freetype
	)
	v4l? ( media-libs/libv4l )
	vlc? ( media-video/vlc:= )
"
RDEPEND="${DEPEND}"

post_src_unpack() {
	mv ${WORKDIR}/obsproject-obs-studio-??????? ${S} || die
	mv ${WORKDIR}/obs-amd-encoder-*/* ${S}/plugins/enc-amf/ || die
	mv ${WORKDIR}/obs-browser-*/* ${S}/plugins/obs-browser/ || die
	mv ${WORKDIR}/obs-websocket-*/* ${S}/plugins/obs-websocket/ || die
	mv ${WORKDIR}/asio-*/* ${S}/plugins/obs-websocket/deps/asio || die
	mv ${WORKDIR}/json-*/* ${S}/plugins/obs-websocket/deps/json || die
	mv ${WORKDIR}/QR-Code-generator-*/* ${S}/plugins/obs-websocket/deps/qr || die
	mv ${WORKDIR}/websocketpp-*/* ${S}/plugins/obs-websocket/deps/websocketpp || die

	rm -r ${WORKDIR}/obs-amd-encoder-* || die
	rm -r ${WORKDIR}/obs-browser-* || die
	rm -r ${WORKDIR}/obs-websocket-* || die
	rm -r ${WORKDIR}/asio-* || die
	rm -r ${WORKDIR}/json-*  || die
	rm -r ${WORKDIR}/QR-Code-generator-*  || die
	rm -r ${WORKDIR}/websocketpp-* || die
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DENABLE_ALSA=$(usex alsa)
		-DBUILD_BROWSER=$(usex browser)
		-DENABLE_WAYLAND=$(usex wayland)
		-DENABLE_FREETYPE=$(usex truetype)
		-DENABLE_JACK=$(usex jack)
		-DENABLE_LIBFDK=$(usex fdk)
		-DENABLE_PIPEWIRE=$(usex pipewire)
		-DENABLE_PULSEAUDIO=$(usex pulseaudio)
		-DENABLE_SPEEXDSP=$(usex speex)
		-DENABLE_V4L2=$(usex v4l)
		-DENABLE_VLC=$(usex vlc)
		# FL-8476: imagemagick support is going away upstream, so we need to
		# force disable it in our ebuild to avoid failures.
		-DOBS_MULTIARCH_SUFFIX=${libdir#lib}
		-DUNIX_STRUCTURE=1
		-DWITH_RTMPS=$(usex ssl)
		-DOBS_VERSION_OVERRIDE=${PV}
		# FIXME: No info about this in the install instructions?
		-DBUILD_VST=OFF
	)

#	if use browser; then
		mycmakeargs+=(
			-DCEF_ROOT_DIR="../cef_binary_5060_linux64"
		)
#	fi

	if use luajit || use python; then
		mycmakeargs+=(
			-DDISABLE_LUA=$(usex !luajit)
			-DDISABLE_PYTHON=$(usex !python)
			-DENABLE_SCRIPTING=yes
		)
	else
		mycmakeargs+=( -DENABLE_SCRIPTING=no )
	fi

	cmake-utils_src_configure
}

pkg_postinst() {
	xdg_icon_cache_update

	if ! use alsa && ! use pulseaudio; then
		elog
		elog "For the audio capture features to be available,"
		elog "either the 'alsa' or the 'pulseaudio' USE-flag needs to"
		elog "be enabled."
		elog
	fi

	if ! has_version "sys-apps/dbus"; then
		elog
		elog "The 'sys-apps/dbus' package is not installed, but"
		elog "could be used for disabling hibernating, screensaving,"
		elog "and sleeping.  Where it is not installed,"
		elog "'xdg-screensaver reset' is used instead"
		elog "(if 'x11-misc/xdg-utils' is installed)."
		elog
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
}
