# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools linux-info

DESCRIPTION="GFS2 Utilities"
HOMEPAGE="https://pagure.io/gfs2-utils"
SRC_URI="https://releases.pagure.org/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND="sys-cluster/corosync
	sys-cluster/openais
	sys-cluster/liblogthread
	sys-cluster/libccs
	sys-cluster/libfence
	sys-cluster/libdlm
	sys-libs/ncurses"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${P}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		--localstatedir=/var
}

src_compile() {
	# parallel build is broken
	emake -j1
}

src_install() {
	default
	rm -rf "${D}/usr/share/doc"
	dodoc doc/*.txt

	keepdir /var/{lib,log}/cluster
}
