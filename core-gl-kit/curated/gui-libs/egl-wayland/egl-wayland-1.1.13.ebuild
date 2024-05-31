# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="EGLStream-based Wayland external platform"
HOMEPAGE="https://github.com/NVIDIA/egl-wayland/"
SRC_URI="
	https://github.com/NVIDIA/egl-wayland/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/wayland
	x11-libs/libdrm
	!<x11-drivers/nvidia-drivers-470.57.02[wayland(-)]
"
DEPEND="
	${RDEPEND}
	dev-libs/wayland-protocols
	gui-libs/eglexternalplatform
	>=media-libs/libglvnd-1.3.4
"
BDEPEND="dev-util/wayland-scanner"

src_install() {
	meson_src_install

	insinto /usr/share/egl/egl_external_platform.d
	doins "${FILESDIR}"/10_nvidia_wayland.json
}
