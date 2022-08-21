# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson flag-o-matic

DESCRIPTION="An audio time-stretching and pitch-shifting library and utility program"
HOMEPAGE="https://www.breakfastquay.com/rubberband/"
SRC_URI="https://breakfastquay.com/files/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="ladspa jni static-libs +programs vamp"

BDEPEND="
	virtual/pkgconfig
"
CDEPEND="
	media-libs/libsamplerate
	sci-libs/fftw:3.0
	jni? ( >=virtual/jdk-1.8:* )
	ladspa? ( media-libs/ladspa-sdk )
	programs? ( media-libs/libsndfile )
	vamp? ( media-libs/vamp-plugin-sdk )
"
RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-build.patch"
)

multilib_src_configure() {
	if use ppc ; then
		# bug #827203
		# meson doesn't respect/use LIBS but mangles LDFLAGS with libs
		# correctly. Use this until we get a Meson test for libatomic.
		append-ldflags -latomic
	fi

	local emesonargs=(
		--buildtype=release
		-Dfft=fftw
		-Dresampler=libsamplerate
		-Ddefault_library=$(use static-libs && echo "both" || echo "shared")
		$(meson_use ladspa)
		$(meson_use jni)
		$(meson_use programs)
		$(meson_use vamp)
	)
	use jni && emesonargs+=(
		-Dextra_include_dirs="$(java-config -g JAVA_HOME)/include,$(java-config -g JAVA_HOME)/include/linux"
	)
	meson_src_configure
}

multilib_src_install_all() {
	! use jni && find "${ED}" -name "*.a" -delete
}
