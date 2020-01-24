# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Manages multiple Ruby versions"
HOMEPAGE="https://www.gentoo.org"
SRC_URI="https://dev.gentoo.org/~graaff/ruby-team/ruby.eselect-${PVR}.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""
RDEPEND=">=app-admin/eselect-1.0.2"
S=${WORKDIR}

src_prepare() {
	eapply -p0 "${FILESDIR}/${P}-funtoo.patch"
	eapply_user
}


src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/ruby.eselect-${PVR}" ruby.eselect || die
}
