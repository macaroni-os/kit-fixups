# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6,7} )

KEYWORDS="~amd64"
SRC_URI="https://github.com/KhronosGroup/Vulkan-ValidationLayers/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Vulkan-ValidationLayers-${PV}"

inherit python-any-r1 cmake-utils

DESCRIPTION="Vulkan Validation Layers"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-ValidationLayers"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="X wayland"

DEPEND="${PYTHON_DEPS}
		>=dev-util/glslang-7.11.3214:=
		>=dev-util/spirv-tools-2019.3:=
		>=dev-util/vulkan-headers-1.1.107
		wayland? ( dev-libs/wayland:= )
		X? (
		x11-libs/libX11:=
		x11-libs/libXrandr:=
		)"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=True
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DBUILD_TESTS=False
		-DGLSLANG_INSTALL_DIR="${EPREFIX}/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr/include/vulkan/"
	)
	cmake-utils_src_configure
}
