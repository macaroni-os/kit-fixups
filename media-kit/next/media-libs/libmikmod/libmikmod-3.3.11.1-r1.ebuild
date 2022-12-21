# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.sourceforge.net/"
SRC_URI="mirror://sourceforge/mikmod/${P}.tar.gz"

LICENSE="LGPL-2+ LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="+alsa coreaudio cpu_flags_ppc_altivec debug nas openal oss pulseaudio cpu_flags_x86_sse2 sdl static-libs +threads"

REQUIRED_USE="|| ( alsa coreaudio nas openal oss sdl pulseaudio )"

RDEPEND="
	!${CATEGORY}/${PN}:2
	alsa? ( >=media-libs/alsa-lib-1.0.27.2:= )
	nas? ( >=media-libs/nas-1.9.4:= )
	openal? ( >=media-libs/openal-1.15.1-r1 )
	pulseaudio? ( >=media-sound/pulseaudio-5.0 )
	sdl? ( media-libs/libsdl2 )
"
DEPEND="${RDEPEND}
	oss? ( virtual/os-headers )
"
BDEPEND="sys-apps/texinfo"

PATCHES=(
	"${FILESDIR}"/${P}-macro-strict-prototypes.patch
)

src_prepare() {
	default

	# USE=debug enables Werror, bug #621688
	sed -i -e 's/-Werror//' configure || die
}

src_configure() {
	local mysimd="--disable-simd"
	if use ppc || use ppc64 || use ppc-macos; then
		mysimd="$(use_enable cpu_flags_ppc_altivec simd)"
	fi
	if use amd64 || use x86 || use amd64-linux || use x86-linux || use x64-macos; then
		mysimd="$(use_enable cpu_flags_x86_sse2 simd)"
	fi

	ECONF_SOURCE=${S} econf \
		$(use_enable alsa) \
		$(use_enable nas) \
		$(use_enable pulseaudio) \
		$(use_enable sdl sdl2) \
		$(use_enable openal) \
		$(use_enable oss) \
		$(use_enable coreaudio osx) \
		$(use_enable debug) \
		$(use_enable threads) \
		$(use_enable static-libs static) \
		--disable-dl \
		${mysimd}
}

src_install() {
	emake DESTDIR="${D}" install
	dosym ${PN}$(get_libname 3) /usr/$(get_libdir)/${PN}$(get_libname 2)

	dodoc AUTHORS NEWS README TODO
	docinto html
	dodoc docs/*.html

	find "${ED}" -name '*.la' -delete || die
}
