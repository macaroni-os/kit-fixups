EAPI=7

PYTHON_COMPAT=( python3_{9..10} )
inherit autotools python-any-r1 toolchain-funcs

MY_P="${P/mit-}"
P_DIR=$(ver_cut 1-2)
DESCRIPTION="MIT Kerberos V"
HOMEPAGE="https://web.mit.edu/kerberos/www/"
SRC_URI="https://web.mit.edu/kerberos/dist/krb5/${P_DIR}/${MY_P}.tar.gz"

LICENSE="openafs-krb5-a BSD MIT OPENLDAP BSD-2 HPND BSD-4 ISC RSA CC-BY-SA-3.0 || ( BSD-2 GPL-2+ )"
SLOT="0"
KEYWORDS="*"
IUSE="cpu_flags_x86_aes doc +keyutils lmdb nls openldap +pkinit selinux +threads test xinetd"

RESTRICT="!test? ( test )"

DEPEND="
	!!app-crypt/heimdal
	>=sys-fs/e2fsprogs-1.46.4-r51
	|| (
		>=dev-libs/libverto-0.2.5[libev]
		>=dev-libs/libverto-0.2.5[libevent]
	)
	keyutils? ( >=sys-apps/keyutils-1.5.8:= )
	lmdb? ( dev-db/lmdb:= )
	nls? ( sys-devel/gettext )
	openldap? ( >=net-nds/openldap-2.4.38-r1:= )
	pkinit? ( >=dev-libs/openssl-1.0.1h-r2:0= )
	xinetd? ( sys-apps/xinetd )
	"
BDEPEND="
	${PYTHON_DEPS}
	virtual/yacc
	cpu_flags_x86_aes? (
		amd64? ( dev-lang/yasm )
		x86? ( dev-lang/yasm )
	)
	doc? ( virtual/latex-base )
	test? ( dev-util/cmocka )
	"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-kerberos )"

S=${WORKDIR}/${MY_P}/src

PATCHES=(
	"${FILESDIR}/${PN}-1.12_warn_cflags.patch"
	"${FILESDIR}/${PN}_dont_create_rundir.patch"
	"${FILESDIR}/${PN}-1.18.2-krb5-config.patch"
)


src_prepare() {
	default
	# Make sure we always use the system copies.
	rm -rf util/{et,ss,verto}
	sed -i 's:^[[:space:]]*util/verto$::' configure.ac || die

	eautoreconf
}

src_configure() {
	ECONF_SOURCE=${S} \
	AR="$(tc-getAR)" \
	WARN_CFLAGS="set" \
	econf \
		$(use_with openldap ldap) \
		$(use_enable nls) \
		$(use_enable pkinit) \
		$(use_enable threads thread-support) \
		$(use_with lmdb) \
		$(use_with keyutils) \
		--without-hesiod \
		--enable-shared \
		--with-system-et \
		--with-system-ss \
		--enable-dns-for-realm \
		--enable-kdc-lookaside-cache \
		--with-system-verto \
		--disable-rpath
}

src_compile() {
	emake -j1
}

src_test() {
	emake -j1 check
}

src_install() {
	emake \
		DESTDIR="${D}" \
		EXAMPLEDIR="${EPREFIX}/usr/share/doc/${PF}/examples" \
		install

	# default database dir
	keepdir /var/lib/krb5kdc

	cd ..
	dodoc README

	if use doc; then
		dodoc -r doc/html
		docinto pdf
		dodoc doc/pdf/*.pdf
	fi

	newinitd "${FILESDIR}"/mit-krb5kadmind.initd-r2 mit-krb5kadmind
	newinitd "${FILESDIR}"/mit-krb5kdc.initd-r2 mit-krb5kdc
	newinitd "${FILESDIR}"/mit-krb5kpropd.initd-r2 mit-krb5kpropd
	newconfd "${FILESDIR}"/mit-krb5kadmind.confd mit-krb5kadmind
	newconfd "${FILESDIR}"/mit-krb5kdc.confd mit-krb5kdc
	newconfd "${FILESDIR}"/mit-krb5kpropd.confd mit-krb5kpropd

	insinto /etc
	newins "${ED}/usr/share/doc/${PF}/examples/krb5.conf" krb5.conf.example
	insinto /var/lib/krb5kdc
	newins "${ED}/usr/share/doc/${PF}/examples/kdc.conf" kdc.conf.example

	if use openldap ; then
		insinto /etc/openldap/schema
		doins "${S}/plugins/kdb/ldap/libkdb_ldap/kerberos.schema"
	fi

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/kpropd.xinetd" kpropd
	fi
}
