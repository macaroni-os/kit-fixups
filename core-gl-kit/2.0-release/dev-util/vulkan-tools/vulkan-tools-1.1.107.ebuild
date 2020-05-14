# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6} )

KEYWORDS="~amd64"
SRC_URI="https://github.com/KhronosGroup/Vulkan-Tools/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Vulkan-Tools-${PV}"

inherit python-any-r1 cmake-utils

DESCRIPTION="Official Vulkan Tools and Utilities for Windows, Linux, Android, and MacOS"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Tools"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+cube +vulkaninfo X wayland"

DEPEND="${PYTHON_DEPS}
	cube? ( dev-util/glslang:= )
	>=dev-util/vulkan-headers-1.1.107
	media-libs/vulkan-loader:=[wayland?,X?]
	wayland? ( dev-libs/wayland:= )
	X? (
		x11-libs/libX11:=
		x11-libs/libXrandr:=
	)"

# Vulkaninfo does not support wayland
REQUIRED_USE="|| ( X wayland )
			vulkaninfo? ( X )"

pkg_setup() {
	MULTILIB_CHOST_TOOLS=()

	if use vulkaninfo; then
		MULTILIB_CHOST_TOOLS+=( /usr/bin/vulkaninfo )
	fi

	if use cube; then
		MULTILIB_CHOST_TOOLS+=(
			/usr/bin/vkcube
			/usr/bin/vkcubepp
		)
	fi

	python-any-r1_pkg_setup
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=True
		-DBUILD_CUBE=$(usex cube)
		-DBUILD_VULKANINFO=$(usex vulkaninfo)
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DGLSLANG_INSTALL_DIR="${EPREFIX}/usr"
		-DVULKAN_HEADERS_INSTALL_DIR="${EPREFIX}/usr"
	)

	# Upstream only supports one window system at a time
	# If X is set at all, even if wayland is set, use X
	#
	# If -cube and/or -vulkaninfo is set, the flags we set
	# are ignored, so we don't need to consider that
	if use X; then
		mycmakeargs+=(
			-DCUBE_WSI_SELECTION="XCB"
		)
	fi

	if ! use X && use wayland; then
		mycmakeargs+=(
			-DCUBE_WSI_SELECTION="WAYLAND"
		)
	fi

	cmake-utils_src_configure
}

multilib_src_install() {
	cmake-utils_src_install
}
