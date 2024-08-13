EAPI=7

inherit autotools edos2unix flag-o-matic pam db-use toolchain-funcs tmpfiles

SASLAUTHD_CONF_VER="2.1.26"

DESCRIPTION="The Cyrus SASL (Simple Authentication and Security Layer)"
HOMEPAGE="https://www.cyrusimap.org/sasl/"
SRC_URI="https://github.com/cyrusimap/${PN}/releases/download/${P}/${P}.tar.gz"


LICENSE="BSD-with-attribution"
SLOT="2"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~mips ~ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="authdaemond berkdb gdbm kerberos ldapdb openldap mysql pam postgres sample selinux sqlite srp ssl static-libs urandom"
REQUIRED_USE="ldapdb? ( openldap )"

# See bug #855890 for sys-libs/db slot
DEPEND="net-mail/mailbase
	authdaemond? ( || ( net-mail/courier-imap mail-mta/courier ) )
	berkdb? ( >=sys-libs/db-4.8.30-r1:4.8 )
	gdbm? ( >=sys-libs/gdbm-1.10-r1:= )
	kerberos? ( >=virtual/krb5-0-r1 )
	openldap? ( >=net-nds/openldap-2.4.38-r1:= )
	mysql? ( dev-db/mysql-connector-c:0= )
	pam? ( >=sys-libs/pam-0-r1 )
	postgres? ( dev-db/postgresql:* )
	sqlite? ( >=dev-db/sqlite-3.8.2:3 )
	ssl? ( >=dev-libs/openssl-1.0.1h-r2:0= )"

RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-sasl )"


PATCHES=(
	"${FILESDIR}"/cyrus-sasl-2.1.25-auxprop.patch
	"${FILESDIR}"/cyrus-sasl-2.1.27-gss_c_nt_hostbased_service.patch
	"${FILESDIR}"/cyrus-sasl-2.1.28-fix-configure-time-check.patch
	"${FILESDIR}"/cyrus-sasl-2.1.28-gdbm-errno-redux.patch
	"${FILESDIR}"/cyrus-sasl-2.1.28-openssl3.patch
	"${FILESDIR}"/cyrus-sasl-2.1.28-static-build.patch
)

src_prepare() {
	default

	# Use plugindir for sasldir
	# https://github.com/cyrusimap/cyrus-sasl/issues/339 (I think)
	sed -i '/^sasldir =/s:=.*:= $(plugindir):' \
		"${S}"/plugins/Makefile.{am,in} || die "sed failed"

	# bug #486740 and bug #468556 (dropped AM_CONFIG_HEADER sed in 2.1.28)
	sed -i -e 's:AC_CONFIG_MACRO_DIR:AC_CONFIG_MACRO_DIRS:g' configure.ac || die

	eautoreconf
}

src_configure() {
	export CC_FOR_BUILD="$(tc-getBUILD_CC)"

	append-flags -fno-strict-aliasing

	if [[ ${CHOST} == *-solaris* ]] ; then
		# getpassphrase is defined in /usr/include/stdlib.h
		append-cppflags -DHAVE_GETPASSPHRASE
	else
		# this horrendously breaks things on Solaris
		append-cppflags -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -DLDAP_DEPRECATED
		# replaces BSD_SOURCE (bug #579218)
		append-cppflags -D_DEFAULT_SOURCE
	fi

	local myeconfargs=(
		--enable-login
		--enable-ntlm
		--enable-auth-sasldb
		--disable-cmulocal
		--disable-krb4
		--disable-macos-framework
		--enable-otp
		--without-sqlite
		--with-saslauthd="${EPREFIX}"/run/saslauthd
		--with-pwcheck="${EPREFIX}"/run/saslauthd
		--with-configdir="${EPREFIX}"/etc/sasl2
		--with-plugindir="${EPREFIX}/usr/$(get_libdir)/sasl2"
		--with-dbpath="${EPREFIX}"/etc/sasl2/sasldb2
		--with-sphinx-build=no
		$(use_with ssl openssl)
		$(use_with pam)
		$(use_with openldap ldap)
		$(use_enable ldapdb)
		$(use_enable sample)
		$(use_enable kerberos gssapi)
		$(use_with mysql mysql "${EPREFIX}"/usr)
		$(use_with postgres pgsql "${EPREFIX}/usr/$(get_libdir)/postgresql")
		$(use_with sqlite sqlite3 "${EPREFIX}/usr/$(get_libdir)")
		$(use_enable srp)
		$(use_enable static-libs static)

		# Add authdaemond support (bug #56523).
		$(usex authdaemond --with-authdaemond="${EPREFIX}"/var/lib/courier/authdaemon/socket '')

		# Fix for bug #59634.
		$(usex ssl '' --without-des)

		# Use /dev/urandom instead of /dev/random (bug #46038).
		$(usex urandom --with-devrandom=/dev/urandom '')
	)

	if   use mysql || use postgres;  then
		myeconfargs+=( --enable-sql )
	else
		myeconfargs+=( --disable-sql )
	fi

	# Default to GDBM if both 'gdbm' and 'berkdb' are present.
	if use gdbm ; then
		einfo "Building with GNU DB as database backend for your SASLdb"
		myeconfargs+=( --with-dblib=gdbm )
	elif use berkdb ; then
		einfo "Building with BerkeleyDB as database backend for your SASLdb"
		myeconfargs+=(
			--with-dblib=berkeley
			--with-bdb-incdir="$(db_includedir)"
		)
	else
		einfo "Building without SASLdb support"
		myeconfargs+=( --with-dblib=none )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_install() {
	default

	if use sample ; then
		docinto sample
		dodoc "${S}"/sample/*.c
		exeinto /usr/share/doc/${P}/sample
		doexe sample/client sample/server
	fi

	dosbin saslauthd/testsaslauthd

	doman man/*

	keepdir /etc/sasl2

	# Reset docinto to default value (bug #674296)
	docinto
	dodoc AUTHORS ChangeLog doc/legacy/TODO
	newdoc pwcheck/README README.pwcheck

	newdoc docsrc/sasl/release-notes/$(ver_cut 1-2)/index.rst release-notes
	edos2unix "${ED}"/usr/share/doc/${PF}/release-notes

	docinto html
	dodoc doc/html/*.html

	if use pam; then
		newpamd "${FILESDIR}"/saslauthd.pam-include saslauthd
	fi

	newinitd "${FILESDIR}"/pwcheck.rc6 pwcheck

	newinitd "${FILESDIR}"/saslauthd2.rc7 saslauthd
	newconfd "${FILESDIR}"/saslauthd-${SASLAUTHD_CONF_VER}.conf saslauthd
	dotmpfiles "${FILESDIR}"/${PN}.conf

	# The get_modname bit is important: do not remove the .la files on
	# platforms where the lib isn't called .so for cyrus searches the .la to
	# figure out what the name is supposed to be instead
	if ! use static-libs && [[ $(get_modname) == .so ]] ; then
		find "${ED}" -name "*.la" -delete || die
	fi
}

pkg_postinst() {
	tmpfiles_process ${PN}.conf

	# Generate an empty sasldb2 with correct permissions.
	if ( use berkdb || use gdbm ) && [[ ! -f "${EROOT}/etc/sasl2/sasldb2" ]] ; then
		einfo "Generating an empty sasldb2 with correct permissions ..."

		echo "p" | "${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -p login \
			|| die "Failed to generate sasldb2"

		"${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -d login \
			|| die "Failed to delete temp user"

		chown root:mail "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chown ${EROOT}/etc/sasl2/sasldb2"
		chmod 0640 "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chmod ${EROOT}/etc/sasl2/sasldb2"
	fi

	if use authdaemond ; then
		elog "You need to add a user running a service using Courier's"
		elog "authdaemon to the 'mail' group. For example, do:"
		elog "	gpasswd -a postfix mail"
		elog "to add the 'postfix' user to the 'mail' group."
	fi

	elog "pwcheck and saslauthd home directories have moved to:"
	elog "  /run/saslauthd, using tmpfiles.d"
}
