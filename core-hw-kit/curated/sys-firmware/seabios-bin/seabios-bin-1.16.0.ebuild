# Distributed under the terms of the GNU General Public License v2

EAPI=7

BINPKG="${P/-bin/}-1"

DESCRIPTION="Open Source implementation of a 16-bit x86 BIOS"
HOMEPAGE="https://www.seabios.org/"
SRC_URI="https://dev.gentoo.org/~ajak/distfiles/${BINPKG}.xpak"
S="${WORKDIR}"

LICENSE="LGPL-3 GPL-3"
SLOT="0"
KEYWORDS="*"

RDEPEND="!sys-firmware/seabios"

src_unpack() {
	tar -x < <(xz -c -d --single-stream "${DISTDIR}/${BINPKG}.xpak") || die "unpacking binpkg failed"
}

src_install() {
	mv usr "${ED}" || die
}
