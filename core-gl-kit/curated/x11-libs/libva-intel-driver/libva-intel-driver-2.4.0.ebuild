# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

AUTOTOOLS_AUTORECONF="yes"

DESCRIPTION="HW video decode support for Intel integrated graphics"
HOMEPAGE="https://github.com/intel/intel-vaapi-driver"
SRC_URI="https://github.com/intel/intel-vaapi-driver/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/intel-vaapi-driver-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="wayland X"

RDEPEND=">=x11-libs/libva-2.0.0:=[X?,wayland?,drm]
	>=x11-libs/libdrm-2.4.52[video_cards_intel]
	wayland? ( >=media-libs/mesa-9.1.6[egl] >=dev-libs/wayland-1.11 )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README )
AUTOTOOLS_PRUNE_LIBTOOL_FILES="all"

src_prepare() {
	sed -e 's/intel-gen4asm/\0diSaBlEd/g' -i configure.ac || die
	eautoreconf || die
	default
}

src_configure() {
	local myeconfargs=(
		$(use_enable wayland)
		$(use_enable X x11)
	)
	econf $myeconfargs || die
}
