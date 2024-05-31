# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Compatibility X server to run under Wayland"
HOMEPAGE="https://wayland.freedesktop.org/xserver.html"
SRC_URI="https://www.x.org/releases/individual/xserver/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="rpc selinux unwind video_cards_nvidia xcsecurity"

DEPEND="
	dev-libs/libbsd
	dev-libs/openssl
	>=dev-libs/wayland-1.21.0
	>=dev-libs/wayland-protocols-1.30
	media-fonts/font-util
	media-libs/libepoxy[X,egl(+)]
	media-libs/libglvnd[X]
	media-libs/mesa[X(+),egl(+),gbm(+)]
	x11-apps/xkbcomp
	>=x11-base/xorg-proto-2022.2
	>=x11-libs/libdrm-2.4.109
	x11-libs/libXau
	x11-libs/libxcvt
	x11-libs/libXdmcp
	x11-libs/libXfont2
	x11-libs/libxkbfile
	>=x11-libs/libxshmfence-1.1
	x11-libs/pixman
	>=x11-libs/xtrans-1.3.5
	selinux? (
		sys-process/audit
		>=sys-libs/libselinux-2.0.86
	)
	unwind? ( sys-libs/libunwind )
	video_cards_nvidia? ( gui-libs/egl-wayland )
"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-xserver )
	!<=x11-base/xorg-server-1.20.11
"

src_configure() {
	local emesonargs=(
		$(meson_use rpc secure-rpc)
		$(meson_use selinux xselinux)
		$(meson_use unwind libunwind)
		$(meson_use xcsecurity)
		$(meson_use video_cards_nvidia xwayland_eglstream)
		-Ddpms=true
		-Ddri3=true
		-Ddtrace=false
		-Dglamor=true
		-Dglx=true
		-Dipv6=true
		-Dscreensaver=true
		-Dsha1=libcrypto
		-Dxace=true
		-Dxdmcp=true
		-Dxinerama=true
		-Dxvfb=true
		-Dxv=true
		-Dxwayland-path="${EPREFIX}"/usr/bin
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	# Part of xorg-server
	rm -f "${ED}"/usr/share/man/man1/Xserver.1 || die

	# Part of xorg-server
	rm -f "${ED}"/usr/lib64/xorg/protocol.txt || die
}

