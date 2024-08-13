# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal toolchain-funcs user

DESCRIPTION="small audio and MIDI framework part of the OpenBSD project"
HOMEPAGE="http://www.sndio.org/"
SRC_URI="http://www.sndio.org/${P}.tar.gz"

LICENSE="ISC"
SLOT="0/7.1"
KEYWORDS="*"
IUSE="alsa"

DEPEND="
	dev-libs/libbsd[${MULTILIB_USEDEP}]
	alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )
"
RDEPEND="${DEPEND}"

pkg_setup(){
	enewuser sndiod -1 -1 -1 audio
}

src_prepare() {
	default
	multilib_copy_sources
}

multilib_src_configure() {
	tc-export CC

	./configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--privsep-user=sndiod \
		--with-libbsd \
		$(use_enable alsa) \
	|| die "Configure failed"
}

src_install() {
	multilib-minimal_src_install

	doinitd "${FILESDIR}/sndiod"
}
