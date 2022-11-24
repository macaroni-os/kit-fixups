# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

SRC_URI="https://github.com/sahlberg/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${P}-remove-ld-iscsi.patch.bz2"

KEYWORDS="*"

DESCRIPTION="iscsi client library and utilities"
HOMEPAGE="https://github.com/sahlberg/libiscsi"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
IUSE="rdma static-libs"

RDEPEND="dev-libs/libgcrypt:0=
	rdma? ( sys-cluster/rdma-core )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.18.0-fno-common.patch
	"${FILESDIR}"/${PN}-1.18.0-fno-common-2.patch
	"${FILESDIR}"/${PN}-1.18.0-fno-common-3.patch
	"${FILESDIR}"/${PN}-1.19.0-fix-rdma-automagic.patch
	"${WORKDIR}"/${P}-remove-ld-iscsi.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-manpages \
		--disable-werror \
		--disable-tests \
		--disable-test-tool \
		--enable-static \
		$(use_enable static-libs static) \
		$(use_with rdma)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
