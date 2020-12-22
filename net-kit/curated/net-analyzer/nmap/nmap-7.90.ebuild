# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="sqlite,xml"
inherit autotools flag-o-matic python-single-r1 toolchain-funcs

MY_P=${P/_beta/BETA}

DESCRIPTION="A utility for network discovery and security auditing"
HOMEPAGE="https://nmap.org/"
SRC_URI="
	https://nmap.org/dist/${MY_P}.tar.bz2
	https://dev.gentoo.org/~jer/nmap-logo-64.png
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="
	ipv6 libressl libssh2 ncat nls nmap-update nping +nse ssl system-lua
"
NMAP_LINGUAS=( de fr hi hr it ja pl pt_BR ru zh )
REQUIRED_USE="
	system-lua? ( nse )
"
RDEPEND="
	dev-libs/liblinear:=
	dev-libs/libpcre
	net-libs/libpcap
	libssh2? ( net-libs/libssh2[zlib] )
	nls? ( virtual/libintl )
	nmap-update? (
		dev-libs/apr
		dev-vcs/subversion
	)
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	system-lua? ( >=dev-lang/lua-5.2:*[deprecated] )
"
DEPEND="
	${RDEPEND}
	nls? ( sys-devel/gettext )
"
PATCHES=(
	"${FILESDIR}"/${PN}-5.10_beta1-string.patch
	"${FILESDIR}"/${PN}-5.21-python.patch
	"${FILESDIR}"/${PN}-6.46-uninstaller.patch
	"${FILESDIR}"/${PN}-6.25-liblua-ar.patch
	"${FILESDIR}"/${PN}-7.25-CXXFLAGS.patch
	"${FILESDIR}"/${PN}-7.25-libpcre.patch
	"${FILESDIR}"/${PN}-7.31-libnl.patch
	"${FILESDIR}"/${PN}-7.80-ac-config-subdirs.patch
	"${FILESDIR}"/${PN}-7.91-no-FORTIFY_SOURCE.patch
)

S="${WORKDIR}/${MY_P}"

src_unpack() {
	# prevent unpacking the logo
	unpack ${MY_P}.tar.bz2
}


src_prepare() {
	rm -r liblinear/ libpcap/ libpcre/ libssh2/ libz/ || die

	cat "${FILESDIR}"/nls.m4 >> "${S}"/acinclude.m4 || die

	default

	sed -i \
		-e '/^ALL_LINGUAS =/{s|$| id|g;s|jp|ja|g}' \
		Makefile.in || die

	cp libdnet-stripped/include/config.h.in{,.nmap-orig} || die

	eautoreconf

	if [[ ${CHOST} == *-darwin* ]] ; then
		# we need the original for a Darwin-specific fix, bug #604432
		mv libdnet-stripped/include/config.h.in{.nmap-orig,} || die
	fi
}


src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	econf \
		$(use_enable ipv6) \
		$(use_enable nls) \
		$(use_with libssh2) \
		$(use_with ncat) \
		$(use_with nmap-update) \
		$(use_with nping) \
		$(use_with ssl openssl) \
		$(usex libssh2 --with-zlib) \
		$(usex nse --with-liblua=$(usex system-lua /usr included '' '') --without-liblua) \
		--without-ndiff \
		--without-zenmap \
		--cache-file="${S}"/config.cache \
		--with-libdnet=included \
		--with-pcre=/usr
	#	Commented out because configure does weird things
	#	--with-liblinear=/usr \
}

src_compile() {
	local directory
	for directory in . libnetutil nsock/src \
		$(usex ncat ncat '') \
		$(usex nmap-update nmap-update '') \
		$(usex nping nping '')
	do
		emake -C "${directory}" makefile.dep
	done

	emake \
		AR=$(tc-getAR) \
		RANLIB=$(tc-getRANLIB)
}

src_install() {
	LC_ALL=C emake -j1 \
		DESTDIR="${D}" \
		STRIP=: \
		nmapdatadir="${EPREFIX}"/usr/share/nmap \
		install
	if use nmap-update;then
		LC_ALL=C emake -j1 \
			-C nmap-update \
			DESTDIR="${D}" \
			STRIP=: \
			nmapdatadir="${EPREFIX}"/usr/share/nmap \
			install
	fi

	dodoc CHANGELOG HACKING docs/README docs/*.txt

}
