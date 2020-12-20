# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal


# Need to fetch a commit because upstream didn't tag the minor release
COMMIT="e4e8d191e8dd74cbdbeaef3232c16a7ef517e68d"

DESCRIPTION="Hybrid lossless audio compression tools"
HOMEPAGE="https://www.wavpack.com/"
SRC_URI="https://github.com/dbry/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND=">=virtual/libiconv-0-r1"
DEPEND="${RDEPEND}"

S="${WORKDIR}/WavPack-${COMMIT}"

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf \
		$(multilib_native_enable apps)
}

multilib_src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
