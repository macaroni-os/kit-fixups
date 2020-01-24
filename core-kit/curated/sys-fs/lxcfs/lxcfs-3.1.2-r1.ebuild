# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd versionator
DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/"
LICENSE="Apache-2.0"
SLOT="0"

UPSTREAM_PV=$(replace_version_separator 3 '.' )
SRC_URI="https://github.com/lxc/lxcfs/archive/${PN}-${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"
S=${WORKDIR}/${PN}-${P}
# Omit all dbus.  Upstream appears to require it because systemd, but
# lxcfs makes no direct use of dbus.
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
	newinitd "${FILESDIR}"/lxcfs-3.1.2-r1.initd lxcfs
	newconfd "${FILESDIR}"/lxcfs-3.1.2-r1.confd lxcfs
	systemd_dounit config/init/systemd/lxcfs.service
}
