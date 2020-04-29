# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd versionator
DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/"
LICENSE="Apache-2.0"
SLOT="0"

UPSTREAM_PV=$(replace_version_separator 3 '.' )
SRC_URI="https://github.com/lxc/lxcfs/archive/${PN}-${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS=""
S=${WORKDIR}/${PN}-${P}

RDEPEND="
	dev-libs/glib:2
	sys-fs/fuse:0
"
DEPEND="
	sys-apps/help2man
	${RDEPEND}
"

src_prepare() {
	default
	./bootstrap.sh || die "Failed to bootstrap configure files"
}

src_configure() {
	# Without the localstatedir the filesystem isn't mounted correctly
	econf --localstatedir=/var
}

src_test() {
	emake tests
	tests/main.sh || die "Tests failed"
}

src_install() {
	default
	newinitd "${FILESDIR}"/${PV}/lxcfs.initd lxcfs
	newconfd "${FILESDIR}"/${PV}/lxcfs.confd lxcfs
}
