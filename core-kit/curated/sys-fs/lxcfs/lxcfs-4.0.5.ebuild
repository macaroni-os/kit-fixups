# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/ https://github.com/lxc/lxcfs/"
SRC_URI="https://github.com/lxc/lxcfs/archive/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

RDEPEND="dev-libs/glib:2
	sys-fs/fuse:0"
DEPEND="${RDEPEND}"
BDEPEND="sys-apps/help2man"

RESTRICT="test"

S="${WORKDIR}/${PN}-${P}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# Without the localstatedir the filesystem isn't mounted correctly
	# Without with-distro ./configure will fail when cross-compiling
	econf --localstatedir=/var --with-distro=gentoo
}

src_test() {
	cd tests/ || die
	emake tests
	./main.sh || die "Tests failed"
}

src_install() {
	default
	newinitd "${FILESDIR}"/${PV}/lxcfs.initd lxcfs
	newconfd "${FILESDIR}"/${PV}/lxcfs.confd lxcfs
}
