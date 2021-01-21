# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit meson python-any-r1

EGIT_COMMIT="e8c0720f3251e50aa8e777f44e3c2406dceb919c"

DESCRIPTION="Extensible Vulkan benchmarking suite with targeted, configurable scenes."
HOMEPAGE="https://github.com/vkmark/vkmark"
SRC_URI="https://github.com/vkmark/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="kms wayland X"

RDEPEND="
	media-libs/assimp
	>=dev-libs/wayland-protocols-1.12
	dev-libs/wayland
	media-libs/glm
	x11-libs/libxcb
	x11-libs/libdrm
	media-libs/mesa[gbm]
	dev-util/vulkan-headers
	media-libs/vulkan-loader
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	${PYTHON_DEPS}
"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use kms)
		$(meson_use wayland)
		$(meson_use X xcb)
	)
	meson_src_configure
}
