# $Header: $

EAPI="6"

inherit multilib rpm

DESCRIPTION="Epson Perfection V10/V100 PHOTO scanner plugin for SANE 'epkowa' backend."
HOMEPAGE="http://www.avasys.jp/english/linux_e/dl_scan.html"
SRC_URI="
        x86?   ( http://pkgs.fedoraproject.org/lookaside/pkgs/iscan-firmware/iscan-plugin-gt-s600-2.1.2-1.i386.rpm/0a3a83dbbb2630c5e9453cc78983ab81/iscan-plugin-gt-s600-2.1.2-1.i386.rpm )
        amd64? ( https://src.fedoraproject.org/repo/extras/iscan-firmware/iscan-plugin-gt-s600-2.1.2-1.x86_64.rpm/9e36fd80b1f8ffa3f658b6a025d5e186/iscan-plugin-gt-s600-2.1.2-1.x86_64.rpm )"

LICENSE="AVASYS Public License"
SLOT="0"
KEYWORDS="~x86 amd64"

IUSE=""
S=${WORKDIR}

DEPEND=">=media-gfx/iscan-2.18.0"
RDEPEND="${DEPEND}"

src_install() {
	# install scanner firmware
	insinto /usr/share/iscan
	doins "${WORKDIR}"/usr/share/iscan/*

	# install docs
	dodoc usr/share/doc/"${P}"/AVASYSPL.ja.txt
	dodoc usr/share/doc/"${P}"/AVASYSPL.en.txt

	# install scanner plugins
	insinto /usr/$(get_libdir)/iscan
	doins "${WORKDIR}"/usr/$(get_libdir)/iscan/*
}

pkg_postinst() {
	if [[ ${ROOT} == / ]]; then
		# Needed for scanner to work properly.
		iscan-registry --add interpreter usb 0x04b8 0x012d /usr/$(get_libdir)/iscan/libesint66 /usr/share/iscan/esfw66.bin
	fi
	
	elog
	elog "Firmware file esfw66.bin for Epson Perfection V10 /"
	elog "V100 PHOTO has been installed in /usr/share/iscan and"
	elog "registered for use"
}

pkg_prerm() {
	if [[ ${ROOT} == / ]]; then
		# Uninstall interpreter from iscan-registry before removal
		iscan-registry --remove interpreter usb 0x04b8 0x012d /usr/$(get_libdir)/iscan/libesint66 /usr/share/iscan/esfw66.bin
	fi	
}

