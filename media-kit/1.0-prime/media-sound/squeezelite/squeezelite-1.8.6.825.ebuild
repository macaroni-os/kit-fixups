# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3 user

DESCRIPTION="Squeezelite is a small headless Squeezebox emulator for Linux using ALSA audio output"
HOMEPAGE="https://github.com/ralph-irving/squeezelite"

EGIT_REPO_URI="https://github.com/ralph-irving/squeezelite.git"
EGIT_COMMIT="1b96b62552afea580dfa60b14b71ee79491a5dd0"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="+dsd +ffmpeg +resample lirc gpio visexport"

DEPEND="media-libs/alsa-lib
		media-libs/flac
		media-libs/faad2
		media-libs/libvorbis
		media-libs/libmad
		media-sound/mpg123
		ffmpeg? ( media-video/ffmpeg )
		lirc? ( lib-misc/lirc )
		resample? ( media-libs/soxr )"

RDEPEND="${DEPEND} media-sound/alsa-utils"

src_compile() {
	OPTS="-DLINKALL"
	use dsd && OPTS="$OPTS -DDSD"
	use ffmpeg && OPTS="$OPTS -DFFMPEG"
	use resample && OPTS="$OPTS -DRESAMPLE"
	use visexport && OPTS="$OPTS -DVISEXPORT"
	use lirc && OPTS="$OPTS -DIR"
	use gpio && OPTS="$OPTS -DGPIO"
	export CFLAGS="$CFLAGS $OPTS"
	export LDFLAGS="$LDFLAGS -lasound -lpthread -lm -lrt"
	emake || die "emake failed"
}

src_install() {
	dobin squeezelite
	dodoc LICENSE.txt
	newconfd "${FILESDIR}/squeezelite-1.8.conf.d" "${PN}"
	newinitd "${FILESDIR}/squeezelite-1.8.init.d" "${PN}"
}

pkg_postinst() {
	# Provide some post-installation tips.
	elog "If you want start Squeezelite automatically on system boot:"
	elog "  rc-update add squeezelite default"
	elog "Edit /etc/cond.d/squeezelite to customise -- in particular"
	elog "you may want to set the audio device to be used."
}
