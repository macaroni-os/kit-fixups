# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="https://dri.freedesktop.org/"
SRC_URI="https://dri.freedesktop.org/libdrm/${P}.tar.xz"
KEYWORDS="*"
VIDEO_CARDS="amdgpu exynos freedreno intel nouveau omap radeon tegra vc4 vivante vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

# libkms currently does nothing:
IUSE="${IUSE_VIDEO_CARDS} libkms valgrind"
RESTRICT="test" # see bug #236845
LICENSE="MIT"
SLOT="0"

RDEPEND="video_cards_intel? ( >=x11-libs/libpciaccess-0.13.1-r1:= )"
DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )"

src_configure() {
	local emesonargs=(
		# Udev is only used by tests now.
		-Dudev=false
		-Dcairo-tests=disabled
		$(meson_feature video_cards_amdgpu amdgpu)
		$(meson_feature video_cards_exynos exynos)
		$(meson_feature video_cards_freedreno freedreno)
		$(meson_feature video_cards_intel intel)
		$(meson_feature video_cards_nouveau nouveau)
		$(meson_feature video_cards_omap omap)
		$(meson_feature video_cards_radeon radeon)
		$(meson_feature video_cards_tegra tegra)
		$(meson_feature video_cards_vc4 vc4)
		$(meson_feature video_cards_vivante etnaviv)
		$(meson_feature video_cards_vmware vmwgfx)
		# valgrind installs its .pc file to the pkgconfig for the primary arch
		$(meson_feature valgrind)
	)
	meson_src_configure
}
