# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/ https://github.com/lxc/lxcfs/"
SRC_URI="https://linuxcontainers.org/downloads/lxcfs/${P}.tar.gz"

LICENSE="Apache-2.0 LGPL-2+"
SLOT="0"
KEYWORDS="*"

RDEPEND="sys-fs/fuse:3"
DEPEND="${RDEPEND}"
BDEPEND="sys-apps/help2man"

# Looks like these won't ever work in a container/chroot environment. #764620
RESTRICT="test"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# Needed for x86 support, bug #819762
	# May be able to drop when/if ported to meson, but re-test w/ x86 chroot
	append-lfs-flags

	# Without the localstatedir the filesystem isn't mounted correctly
	# Without with-distro ./configure will fail when cross-compiling
	econf --localstatedir=/var --with-distro=gentoo --disable-static
}

src_test() {
	cd tests/ || die
	emake -j1 tests
	./main.sh || die "Tests failed"
}

src_install() {
	default

	newinitd "${FILESDIR}"/${PV}/lxcfs.initd lxcfs
	newconfd "${FILESDIR}"/${PV}/lxcfs.confd lxcfs

	find "${ED}" -name '*.la' -delete || die
}
