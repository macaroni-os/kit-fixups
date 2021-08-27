# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4..7} )

inherit python-single-r1

DESCRIPTION="Manage your package.use, keeping track and comments on changes made."
HOMEPAGE="https://gitlab.com/apinsard/chuse"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
SRC_URI="https://github.com/apinsard/chuse/archive/${PV}.tar.gz -> ${P}.tar.gz"

DEPEND="|| ( dev-python/appi:0/0.1 dev-python/appi:0/0.2 )"
RDEPEND="${DEPEND}"

src_prepare() {
	einfo "Converting shebangs for python3..."
	python_fix_shebang chuse
	eapply_user
}

src_compile() {
	mkdir -p man
	pod2man chuse.pod > man/chuse.1
}

src_install() {
	into /usr/
	dosbin chuse
	doman man/chuse.1
	dodoc ChangeLog
}

pkg_info() {
	"${ROOT}"/usr/sbin/chuse --version
}

pkg_postinst() {
	elog "If this is the first time you install chuse, you may have to setup"
	elog "your package.use hierarchy pattern. For details, please see the"
	elog "EXAMPLES section of chuse(1) manual page."
}
