# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PHP_EXT_NAME="stomp"
DOCS=( CREDITS doc/classes.php doc/functions.php )

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="PHP extension to communicate with Stomp message brokers"
LICENSE="PHP-3.01"
SLOT="7"
IUSE="examples ssl test"

DEPEND="${DEPEND}
	php_targets_php7-4? ( dev-lang/php:7.4[ssl?] )
	php_targets_php7-2? ( dev-lang/php:7.2[ssl?] )
	php_targets_php7-3? ( dev-lang/php:7.3[ssl?] )
"

RDEPEND="${DEPEND}"

DEPEND="virtual/pkgconfig ${DEPEND}"

src_prepare() {
	if use php_targets_php7-4 || use php_targets_php7-2 || use php_targets_php7-3 ; then
		php-ext-source-r3_src_prepare
	else
		default
	fi
}

src_configure() {
	if use php_targets_php7-4 || use php_targets_php7-2 || use php_targets_php7-3 ; then
		local PHP_EXT_ECONF_ARGS=(
			--enable-stomp
			--with-openssl-dir=$(usex ssl yes no)
		)
		php-ext-source-r3_src_configure
	fi
}

src_install() {
	if use php_targets_php7-4 || use php_targets_php7-2 || use php_targets_php7-3 ; then
		php-ext-pecl-r3_src_install
	fi
}
