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

src_configure() {
	econf \
		$(use_enable static-libs static) \
		GPG_ERROR_CONFIG="${EROOT}/usr/bin/${CHOST}-gpg-error-config" \
		LIBGCRYPT_CONFIG="${EROOT}/usr/bin/${CHOST}-libgcrypt-config" \
		$("${S}/configure" --help | grep -- '--without-.*-prefix' | sed -e 's/^ *\([^ ]*\) .*/\1/g')
}

src_install() {
	default
	# ppl need to use lib*-config for --cflags and --libs
	find "${D}" -name '*.la' -delete || die
}
