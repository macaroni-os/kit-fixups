# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Video Acceleration (VA) API for Linux"
HOMEPAGE="https://01.org/linuxmedia/vaapi"

SRC_URI="https://github.com/intel/libva/releases/download/${PV}/${P}.tar.bz2"
KEYWORDS="*"

LICENSE="MIT"
SLOT="0/$(ver_cut 1)"
IUSE="+drm opengl utils vdpau wayland X"

VIDEO_CARDS="nvidia intel i965 nouveau"
for x in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${x}"
done

RDEPEND="
	>=x11-libs/libdrm-2.4.46
	opengl? ( >=virtual/opengl-7.0-r1 )
	wayland? ( >=dev-libs/wayland-1.11 )
	X? (
		>=x11-libs/libX11-1.6.2
		>=x11-libs/libXext-1.3.2
		>=x11-libs/libXfixes-5.0.1
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"
PDEPEND="video_cards_nvidia? ( >=x11-libs/libva-vdpau-driver-0.7.4-r1 )
	video_cards_nouveau? ( >=x11-libs/libva-vdpau-driver-0.7.4-r3 )
	vdpau? ( >=x11-libs/libva-vdpau-driver-0.7.4-r1 )
	video_cards_intel? ( >=x11-libs/libva-intel-driver-2.0.0 )
	video_cards_i965? ( >=x11-libs/libva-intel-driver-2.0.0 )
	utils? ( media-video/libva-utils )
"

REQUIRED_USE="|| ( drm wayland X )
	opengl? ( X )"

DOCS=( NEWS )

MULTILIB_WRAPPED_HEADERS=(
/usr/include/va/va_backend_glx.h
/usr/include/va/va_x11.h
/usr/include/va/va_dri2.h
/usr/include/va/va_dricommon.h
/usr/include/va/va_glx.h
)

src_prepare() {
	default
}

src_configure() {
	local myeconfargs=(
		--with-drivers-path="${EPREFIX}/usr/$(get_libdir)/va/drivers"
		$(use_enable opengl glx)
		$(use_enable X x11)
		$(use_enable wayland)
		$(use_enable drm)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
