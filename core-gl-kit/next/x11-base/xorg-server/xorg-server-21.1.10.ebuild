# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="x.org X server"
HOMEPAGE="https://www.x.org/wiki"
SRC_URI="https://www.x.org/releases/individual/xserver/${P}.tar.xz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE_SERVERS="kdrive xephyr xnest xorg xvfb"
IUSE="${IUSE_SERVERS} debug +elogind minimal selinux +suid test +udev unwind xcsecurity"

DEPEND="
	dev-libs/libbsd
	dev-libs/openssl
	media-libs/libglvnd[X]
	sys-devel/flex
	x11-apps/xkbcomp
	>=x11-base/xorg-proto-2021.4.99.2
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXfont2-2.0.1
	>=x11-libs/libdrm-2.4.89
	>=x11-libs/libpciaccess-0.12.901
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/libxshmfence-1.1
	>=x11-libs/pixman-0.27.2
	>=x11-libs/xtrans-1.3.5
	>=x11-misc/xkeyboard-config-2.4.1-r3
	elogind? (
		sys-apps/dbus
		sys-auth/elogind[pam]
		sys-libs/pam[elogind]
	)
	kdrive? (
		>=x11-libs/libXext-1.0.99.4
		x11-libs/libXv
	)
	udev? ( virtual/libudev )
	unwind? ( sys-libs/libunwind )
	xephyr? (
		x11-libs/libxcb
		x11-libs/xcb-util
		x11-libs/xcb-util-image
		x11-libs/xcb-util-keysyms
		x11-libs/xcb-util-renderutil
		x11-libs/xcb-util-wm
	)
	xnest? (
		>=x11-libs/libXext-1.0.99.4
		>=x11-libs/libX11-1.1.5
	)
	xorg? (
		>=x11-apps/xinit-1.3.3-r1
		>=x11-libs/libxcvt-0.1.2
	)
	!minimal? (
		>=x11-libs/libXext-1.0.99.4
		>=x11-libs/libX11-1.1.5
		>=media-libs/mesa-18[X(+),egl(+),gbm(+)]
		>=media-libs/libepoxy-1.5.4[X,egl(+)]
	)
"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-xserver )
	xorg? ( x11-base/xorg-drivers )
"

src_configure() {
	local emesonargs=(
		--localstatedir "${EPREFIX}"/var
		--sysconfdir "${EPREFIX}"/etc/X11
		--buildtype $(usex debug debug plain)
		-Db_ndebug=$(usex debug false true)
		$(meson_use !minimal dri1)
		$(meson_use !minimal dri2)
		$(meson_use !minimal dri3)
		$(meson_use !minimal glamor)
		$(meson_use !minimal glx)
		$(meson_use udev)
		$(meson_use udev udev_kms)
		$(meson_use unwind libunwind)
		$(meson_use xcsecurity)
		$(meson_use selinux xselinux)
		$(meson_use xephyr)
		$(meson_use xnest)
		$(meson_use xorg)
		$(meson_use xvfb)
		-Ddocs=false
		-Ddrm=true
		-Ddtrace=false
		-Dipv6=true
		-Dhal=false
		-Dlinux_acpi=false
		-Dlinux_apm=false
		-Dsecure-rpc=false
		-Dsha1=libcrypto
		-Dxkb_output_dir="${EPREFIX}"/var/lib/xkb
		-Dxkb_dir="${EPREFIX}"/usr/share/X11/xkb
		-Dsystemd_logind=true
		$(meson_use suid suid_wrapper)
		)

	meson_src_configure
}

src_install() {
	meson_src_install

	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup
	newinitd "${FILESDIR}"/xdm.initd-14 xdm
	newconfd "${FILESDIR}"/xdm.confd-4 xdm

	# The meson build system does not support install-setuid
	if ! use elogind; then
		if use suid; then
			chmod u+s "${ED}"/usr/bin/Xorg
		fi
	fi

	if ! use xorg; then
		rm -f "${ED}"/usr/share/man/man1/Xserver.1x \
			"${ED}"/usr/$(get_libdir)/xserver/SecurityPolicy \
			"${ED}"/usr/$(get_libdir)/pkgconfig/xorg-server.pc \
			"${ED}"/usr/share/man/man1/Xserver.1x || die
	fi

	# install the @x11-module-rebuild set for Portage
	insinto /usr/share/portage/config/sets
	newins "${FILESDIR}"/xorg-sets.conf xorg.conf
}

pkg_postrm() {
	# Get rid of module dir to ensure opengl-update works properly
	if [[ -z ${REPLACED_BY_VERSION} && -e ${EROOT}/usr/$(get_libdir)/xorg/modules ]]; then
		rm -rf "${EROOT}"/usr/$(get_libdir)/xorg/modules
	fi
}

