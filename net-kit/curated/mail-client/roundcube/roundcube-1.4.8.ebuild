# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit webapp

DESCRIPTION="A browser-based multilingual IMAP client with an application-like user interface"
HOMEPAGE="https://roundcube.net"
SRC_URI="https://api.github.com/repos/roundcube/roundcubemail/tarball/1.4.8 -> roundcube-1.4.8.tar.gz"

# roundcube is GPL-licensed, the rest of the licenses here are
# for bundled PEAR components, googiespell and utf8.class.php
LICENSE="GPL-3 BSD PHP-2.02 PHP-3 MIT public-domain"
KEYWORDS="*"

IUSE="change-password enigma ldap mysql postgres sqlite ssl spell"
REQUIRED_USE="|| ( mysql postgres sqlite )"

# this function only sets DEPEND so we need to include that in RDEPEND
need_httpd_cgi

RDEPEND="
	${DEPEND}
	>=dev-lang/php-5.4.0[filter,gd,iconv,json,ldap?,pdo,postgres?,session,sqlite?,ssl?,unicode,xml]
	virtual/httpd-php
	change-password? (
		dev-lang/php[sockets]
	)
	enigma? (
		app-crypt/gnupg
	)
	mysql? (
		|| (
			dev-lang/php[mysql]
			dev-lang/php[mysqli]
		)
	)
	spell? ( dev-lang/php[curl,spell] )
	dev-php/PEAR-Net_Socket
	dev-php/PEAR-Auth_SASL
	dev-php/PEAR-Net_IDNA2
	dev-php/PEAR-Mail_Mime
	dev-php/PEAR-Net_SMTP
	dev-php/PEAR-Crypt_GPG

"

src_unpack() {
	unpack ${A} || die
	mv ${WORKDIR}/roundcube-roundcubemail-??????? ${P} || die
}

src_install() {
	webapp_src_preinst

	dodoc CHANGELOG INSTALL README.md UPGRADING

	insinto "${MY_HTDOCSDIR}"
	doins -r [[:lower:]]* SQL
	doins .htaccess

	webapp_serverowned "${MY_HTDOCSDIR}"/logs
	webapp_serverowned "${MY_HTDOCSDIR}"/temp

	webapp_configfile "${MY_HTDOCSDIR}"/config/defaults.inc.php
	webapp_postupgrade_txt en "${FILESDIR}/POST-UPGRADE_complete.txt"

	webapp_src_install
}

pkg_postinst() {
	webapp_pkg_postinst

	if [[ -n ${REPLACING_VERSIONS} ]]; then
		elog "You can review the post-upgrade instructions at:"
		elog "${EROOT%/}/usr/share/webapps/${PN}/${PV}/postupgrade-en.txt"
	fi
}
