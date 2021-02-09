# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="MailDir mailbox synchronizer"
HOMEPAGE="http://isync.sourceforge.net/"
LICENSE="GPL-2"
SLOT="0"

SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${P}.tar.gz"
KEYWORDS="*"

IUSE="libressl sasl ssl zlib"

RDEPEND="
	>=sys-libs/db-4.2:=
	sasl?	( dev-libs/cyrus-sasl )
	ssl?	(
			!libressl?	( >=dev-libs/openssl-0.9.6:0= )
			libressl?	( dev-libs/libressl:0= )
		)
	zlib?	( sys-libs/zlib:0= )
"
DEPEND=${RDEPEND}
BDEPEND="
	dev-lang/perl
"

src_prepare() {
	default
}

src_configure() {
	econf \
		$(use_with ssl) \
		$(use_with sasl) \
		$(use_with zlib)
}
