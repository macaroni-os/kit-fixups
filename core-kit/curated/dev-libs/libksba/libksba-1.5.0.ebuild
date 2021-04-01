# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="X.509 and CMS (PKCS#7) library"
HOMEPAGE="http://www.gnupg.org/related_software/libksba"
SRC_URI="mirror://gnupg/libksba/${P}.tar.bz2"

LICENSE="LGPL-3+ GPL-2+ GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.8"
DEPEND="${RDEPEND}"
BDEPEND="sys-devel/bison"

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		GPG_ERROR_CONFIG="${EROOT}/usr/bin/gpg-error-config"
		LIBGCRYPT_CONFIG="${EROOT}/usr/bin/libgcrypt-config"
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	# ppl need to use lib*-config for --cflags and --libs
	find "${ED}" -type f -name '*.la' -delete || die
}
