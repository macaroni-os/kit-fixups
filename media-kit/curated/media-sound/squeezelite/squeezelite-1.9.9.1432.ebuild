# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils user

DESCRIPTION="Squeezelite is a small headless Squeezebox emulator for Linux using ALSA audio output"
HOMEPAGE="https://github.com/ralph-irving/squeezelite"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="alac +dsd +faad +ffmpeg hw_raspi gpio pulseaudio +resample +ssl lirc opus visexport"
REQUIRED_USE="hw_raspi? ( gpio )"
DEPEND="!pulseaudio? ( media-libs/alsa-lib )
		media-libs/flac
		media-libs/faad2
		media-libs/libvorbis
		media-libs/libmad
		media-sound/mpg123
		hw_raspi? ( dev-embedded/wiringpi )
		alac? ( media-libs/alac )
		ffmpeg? ( media-video/ffmpeg )
		lirc? ( lib-misc/lirc )
		resample? ( media-libs/soxr )
		opus? ( media-sound/opusfile )
		pulseaudio? ( media-sound/pulseaudio )
		ssl? ( dev-libs/openssl )"

RDEPEND="${DEPEND} media-sound/alsa-utils"

GITHUB_REPO="$PN"
GITHUB_USER="ralph-irving"
GITHUB_TAG="575b593"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

src_compile() {
	OPTS="-DLINKALL"
	use alac && OPTS="$OPTS -DALAC"
	use dsd && OPTS="$OPTS -DDSD"
	use ffmpeg && OPTS="$OPTS -DFFMPEG"
	use gpio && OPTS="$OPTS -DGPIO"
	use hw_raspi && OPTS="$OPTS -DRPI"
	use lirc && OPTS="$OPTS -DIR"
	use opus && OPTS="$OPTS -DOPUS"
	# Without this, ALSA will be used automatically by the Makefile:
	use pulseaudio && OPTS="$OPTS -DPULSEAUDIO"
	use resample && OPTS="$OPTS -DRESAMPLE"
	use ssl && OPTS="$OPTS -DSSL"
	use visexport && OPTS="$OPTS -DVISEXPORT"
	export CFLAGS="$CFLAGS"
	export OPTS="$OPTS"
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
	elog "Edit /etc/conf.d/squeezelite to customise -- in particular"
	elog "you may want to set the audio device to be used."
}
