# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/ https://github.com/lxc/lxcfs/"
SRC_URI="https://linuxcontainers.org/downloads/lxcfs/${P}.tar.gz"

LICENSE="Apache-2.0 LGPL-2+"
SLOT="0"
KEYWORDS=""

RDEPEND="
	sys-fs/fuse:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-apps/help2man
	dev-python/jinja
"

# Looks like these won't ever work in a container/chroot environment. #764620
RESTRICT="test"

pkg_setup() {
	export BUILD_DIR=${WORKDIR}/build
}

src_configure() {
	local emesonargs=(
		--localstatedir "${EPREFIX}/var"
		-Dinit-script=openrc
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	newinitd "${FILESDIR}"/5.0.0/lxcfs.initd lxcfs
	newconfd "${FILESDIR}"/5.0.0/lxcfs.confd lxcfs

	find "${ED}" -name '*.la' -delete || die

	# we are using own init scripts, so do not need included
	rm -rf "${ED}"/etc/rc.d
}
