# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Bluetooth Audio ALSA Backend"
HOMEPAGE="https://github.com/Arkq/bluez-alsa"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Arkq/${PN}"
else
	SRC_URI="https://github.com/Arkq/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="aac debug hcitop static-libs"

RDEPEND=">=dev-libs/glib-2.26[dbus]
	>=media-libs/alsa-lib-1.0
	>=media-libs/sbc-1.2
	>=net-wireless/bluez-5.0
	aac? ( >=media-libs/fdk-aac-0.1.1 )
	hcitop? (
		dev-libs/libbsd
		sys-libs/ncurses:0=
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	default
	eapply "${FILESDIR}"/${PN}-configdir.patch
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-rfcomm
		--with-alsaconfdir=/usr/share/alsa
		$(use_enable aac)
		$(use_enable debug)
		$(use_enable static-libs static)
		$(use_enable hcitop)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name "*.la" -delete || die

	newinitd "${FILESDIR}"/bluealsa-init.d bluealsa
	newconfd "${FILESDIR}"/bluealsa-conf.d-2 bluealsa

	dodir /etc/alsa/conf.d
	dosym ../../../usr/share/alsa/conf.d/20-bluealsa.conf /etc/alsa/conf.d/20-bluealsa.conf
}

pkg_postinst() {
	elog "Users can use this service when they are members of the \"audio\" group."
}
