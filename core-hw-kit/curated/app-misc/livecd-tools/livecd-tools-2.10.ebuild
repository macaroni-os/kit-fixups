# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info

DESCRIPTION="Gentoo LiveCD tools for autoconfiguration of hardware"
HOMEPAGE="https://gitweb.gentoo.org/proj/livecd-tools.git/"

SRC_URI="https://gitweb.gentoo.org/proj/livecd-tools.git/snapshot/${P}.tar.bz2"
KEYWORDS="amd64"

SLOT="0"
LICENSE="GPL-2"

RDEPEND="
	dev-util/dialog
	media-sound/alsa-utils
	net-dialup/mingetty
	sys-apps/openrc
	sys-apps/pciutils
"

pkg_setup() {
	ewarn "This package is designed for use on the LiveCD only and will do"
	ewarn "unspeakably horrible and unexpected things on a normal system."
	ewarn "YOU HAVE BEEN WARNED!!!"

	CONFIG_CHECK="~SND_PROC_FS"
	linux-info_pkg_setup
}

src_install() {
	doconfd conf.d/*
	doinitd init.d/*
	dosbin net-setup
	into /
	dosbin livecd-functions.sh
}
