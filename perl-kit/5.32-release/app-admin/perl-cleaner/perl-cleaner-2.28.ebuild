# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit prefix

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="https://www.gentoo.org/proj/en/perl/"

SRC_URI="mirror://gentoo/${P}.tar.bz2 https://dev.gentoo.org/~dilfridge/distfiles/${P}.tar.bz2"
KEYWORDS="*"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="app-shells/bash
	dev-lang/perl
	|| (
		( sys-apps/portage app-portage/portage-utils )
		sys-apps/pkgcore
	)
"

src_prepare() {
	default
	eprefixify ${PN}
}

src_install() {
	dosbin perl-cleaner
	doman perl-cleaner.1
}
