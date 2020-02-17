# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6,7} )

KEYWORDS="amd64"
SRC_URI="https://github.com/KhronosGroup/Vulkan-Loader/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Vulkan-Loader-${PV}"

inherit python-any-r1 cmake-utils

DESCRIPTION="Vulkan Installable Client Driver (ICD) Loader"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Loader"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="layers wayland X"

PDEPEND="layers? ( media-libs/vulkan-layers:= )"
DEPEND="${PYTHON_DEPS}
	>=dev-util/vulkan-headers-1.1.107
	wayland? ( dev-libs/wayland:= )
	X? (
		x11-libs/libX11:=
		x11-libs/libXrandr:=
	)"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=True
		-DBUILD_TESTS=False
		-DBUILD_LOADER=True
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DVULKAN_HEADERS_INSTALL_DIR="${EPREFIX}/usr"
	)
	cmake-utils_src_configure
}

src_install() {
	keepdir /etc/vulkan/icd.d
	cmake-utils_src_install
}

pkg_postinst() {
	einfo "USE=demos has been dropped as per upstream packaging"
	einfo "vulkaninfo is now available in the dev-util/vulkan-tools package"
}
