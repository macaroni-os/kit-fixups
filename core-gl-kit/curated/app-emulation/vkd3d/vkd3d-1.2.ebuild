# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-minimal

KEYWORDS="*"
SRC_URI="https://dl.winehq.org/vkd3d/source/${P}.tar.xz"

#Tests fail: https://bugs.gentoo.org/838655
RESTRICT="test"

IUSE="spirv-tools"
RDEPEND="spirv-tools? ( dev-util/spirv-tools:=[${MULTILIB_USEDEP}] )
		media-libs/vulkan-loader[${MULTILIB_USEDEP},X]
		x11-libs/xcb-util:=[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-keysyms:=[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-wm:=[${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
		dev-util/spirv-headers
		dev-util/vulkan-headers"

DESCRIPTION="D3D12 to Vulkan translation library"
HOMEPAGE="https://source.winehq.org/git/vkd3d.git/"

LICENSE="LGPL-2.1"
SLOT="0"

multilib_src_configure() {
	local myconf=(
		$(use_with spirv-tools)
		--disable-doxygen-pdf
	)

	ECONF_SOURCE=${S} econf "${myconf[@]}"
}
