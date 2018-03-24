# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils gnome2-utils pax-utils rpm multilib-build xdg-utils

DESCRIPTION="Instant messaging client, with support for audio and video"
HOMEPAGE="https://www.skype.com/"
SRC_URI="https://repo.skype.com/rpm/stable/${PN}_${PV}-1.x86_64.rpm"

LICENSE="Skype-TOS MIT MIT-with-advertising BSD-1 BSD-2 BSD Apache-2.0 Boost-1.0 ISC CC-BY-SA-3.0 CC0-1.0 openssl ZLIB APSL-2 icu Artistic-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 -*"
IUSE="pax_kernel"

S="${WORKDIR}"
QA_PREBUILT="*"
RESTRICT="mirror bindist strip" #299368

RDEPEND="
	app-crypt/libsecret
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/libv4l
	net-print/cups
	sys-apps/dbus
	sys-devel/gcc[cxx]
	virtual/ttf-fonts
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbfile
	x11-libs/pango
"
src_unpack() {
	rpm_src_unpack ${A}
}

src_prepare() {
	default
	sed -e "s!^SKYPE_PATH=.*!SKYPE_PATH=${EPREFIX}/opt/skypeforlinux/skypeforlinux!" \
		-i usr/bin/skypeforlinux || die
	sed -e "s!^Exec=/usr/!Exec=${EPREFIX}/opt/!" \
		-e "s!^Categories=.*!Categories=Network;InstantMessaging;Telephony;!" \
		-e "/^OnlyShowIn=/d" \
		-i usr/share/applications/skypeforlinux.desktop || die
}

src_install() {
	dodir /opt
	cp -a usr/share/skypeforlinux "${D}"/opt || die

	into /opt
	dobin usr/bin/skypeforlinux

	dodoc usr/share/skypeforlinux/*.html
	dodoc -r usr/share/doc/skypeforlinux/.
	# symlink required for the "Help->3rd Party Notes" menu entry  (otherwise frozen skype -> xdg-open)
	dosym ${P} usr/share/doc/skypeforlinux

	doicon usr/share/pixmaps/skypeforlinux.png

	# compat symlink for the autostart desktop file
	dosym ../../opt/bin/skypeforlinux usr/bin/skypeforlinux

	local res
	for res in 16 32 256 512; do
		newicon -s ${res} usr/share/icons/hicolor/${res}x${res}/apps/skypeforlinux.png skypeforlinux.png
	done

	domenu usr/share/applications/skypeforlinux.desktop

	if use pax_kernel; then
		pax-mark -m "${ED%/}"/opt/skypeforlinux/skypeforlinux
		pax-mark -m "${ED%/}"/opt/skypeforlinux/resources/app.asar.unpacked/node_modules/slimcore/bin/slimcore.node
		ewarn "You have set USE=pax_kernel meaning that you intend to run"
		ewarn "${PN} under a PaX enabled kernel. To do so, we must modify"
		ewarn "the ${PN} binary itself and this *may* lead to breakage! If"
		ewarn "you suspect that ${PN} is being broken by this modification,"
		ewarn "please open a bug."
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
