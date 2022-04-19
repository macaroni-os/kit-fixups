# Distributed under the terms of the GNU General Public License v2

EAPI=6

SRC_URI="https://dev.gentoo.org/~mgorny/dist/${P}.tar.bz2"
KEYWORDS="*"

DESCRIPTION="Eselect module for management of multiple Python versions"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Python"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# python-exec-2.4.2 for working -l option
RDEPEND=">=app-admin/eselect-1.2.3
	>=dev-lang/python-exec-2.4.2-r2"

src_prepare() {
	default
	[[ ${PV} == "99999999" ]] && eautoreconf
}

pkg_postinst() {
	local py

	if has_version 'dev-lang/python'; then
		eselect python update --if-unset
	fi

	if has_version "=dev-lang/python-3*"; then
		eselect python update "--python3" --if-unset
	fi
}
