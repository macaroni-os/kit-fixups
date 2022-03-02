# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PKG=manpages-pl-${PV}

DESCRIPTION="A collection of Polish translations of Linux manual pages"
HOMEPAGE="https://sourceforge.net/projects/manpages-pl/"
SRC_URI="mirror://sourceforge/manpages-pl/${MY_PKG}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

DOCS=( AUTHORS README )

S="${WORKDIR}/${MY_PKG}"

src_prepare() {
	default

	local manpage
	local noinst_manpages=(
		# sys-apps/shadow
		groups
		# sys-apps/procps
		free
		uptime
	)
	for manpage in ${noinst_manpages[@]} ; do
		rm generated/man1/${manpage}.1
		rm -f po/man1/${manpage}.1.po
	done
}

src_install() {
	emake install DESTDIR="${D}" COMPRESSOR=:
}
