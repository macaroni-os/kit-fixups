# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic

DESCRIPTION="RTMP client, librtmp library intended to stream audio or vide o flash content"
HOMEPAGE="https://rtmpdump.mplayerhq.hu/"

SRC_URI="https://git.ffmpeg.org/gitweb/rtmpdump.git/snapshot/f1b83c10d8beb43fcc70a6e88cf4325499f25857.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-f1b83c1"

# the library is LGPL-2.1, the command is GPL-2
LICENSE="LGPL-2.1 tools? ( GPL-2 )"
KEYWORDS="*"
SLOT="0"
IUSE="gnutls ssl static-libs +tools"

DEPEND="ssl? (
		gnutls? (
			net-libs/gnutls
			dev-libs/nettle
		)
		!gnutls? ( dev-libs/openssl )
		>=sys-libs/zlib-1.2.8-r1
	)"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-swf_vertification_type_2.patch"
	"${FILESDIR}/${PN}-swf_vertification_type_2_part_2.patch"
	"${FILESDIR}/${PN}-fix-chunk-size.patch"
	"${FILESDIR}/${PN}-2.4_p20210219-gcc-11-missing-include.patch"
)


pkg_setup() {
	if ! use ssl; then
		if use gnutls; then
			ewarn "USE='gnutls' is ignored without USE='ssl'."
			ewarn "Please review the local USE flags for this package."
		fi
	fi
}

src_prepare() {
	# fix #571106 by restoring pre-GCC5 inline semantics
	append-cflags -std=gnu89
	# fix Makefile ( bug #298535 , bug #318353 and bug #324513 )
	sed -i 's/\$(MAKEFLAGS)//g' Makefile \
		|| die "failed to fix Makefile"
	sed -i -e 's:OPT=:&-fPIC :' \
		-e 's:OPT:OPTS:' \
		-e 's:CFLAGS=.*:& $(OPT):' librtmp/Makefile \
		|| die "failed to fix Makefile"
	use ssl && use !gnutls && eapply "${FILESDIR}/${PN}-openssl-1.1-v2.patch"
	default
}

src_compile() {
	if use ssl ; then
		if use gnutls ; then
			crypto="GNUTLS"
		else
			crypto="OPENSSL"
		fi
	fi
	if ! use tools ; then
		cd librtmp || die
	fi
	emake OPT="${CFLAGS}" XLDFLAGS="${LDFLAGS}" CRYPTO="${crypto}" SYS=posix
}

src_install() {
	mkdir -p "${ED}"/usr/$(get_libdir) || die
	if use tools ; then
		dodoc README ChangeLog rtmpdump.1.html rtmpgw.8.html
	else
		cd librtmp || die
	fi
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" mandir='$(prefix)/share/man' \
		CRYPTO="${crypto}" libdir="${EPREFIX}/usr/$(get_libdir)" install
	find "${D}" -name '*.la' -delete || die
	use static-libs || find "${D}" -name '*.a' -delete || die
}
