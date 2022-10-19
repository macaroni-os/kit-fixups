# Distributed under the terms of the GNU General Public License v2

EAPI="7"

SRC_URI="https://dev.gentoo.org/~whissi/dist/${PN}/${P}.tar.bz2"
KEYWORDS="*"

DESCRIPTION="Eselect module for management of multiple Rust versions"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Rust"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"

pkg_postinst() {
	if has_version 'dev-lang/rust' || has_version 'dev-lang/rust-bin'; then
		eselect rust update --if-unset
	fi
}
