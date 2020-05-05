# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PHP_EXT_NAME="mailparse"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
PHP_EXT_ECONF_ARGS=""
DOCS=( README.md )

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="PHP extension for parsing and working with RFC822 and MIME compliant messages"
LICENSE="PHP-3.01"
SLOT="7"
IUSE=""

PHPUSEDEPEND="
	php_targets_php7-4? ( dev-lang/php:7.4[unicode] )
	php_targets_php7-3? ( dev-lang/php:7.3[unicode] )
	php_targets_php7-2? ( dev-lang/php:7.2[unicode] )
"
DEPEND="${PHPUSEDEPEND}
	dev-util/re2c"
RDEPEND="${PHPUSEDEPEND}"

src_prepare() {
	if use php_targets_php7-4 || use php_targets_php7-3 || use php_targets_php7-2 ; then
		# Missing test source files in archive.  Fixed upstream in next release.
		rm tests/011.phpt tests/bug001.phpt || die
		php-ext-source-r3_src_prepare
	else
		default
	fi
}

src_install() {
	if use php_targets_php7-4 || use php_targets_php7-3 || use php_targets_php7-2 ; then
		php-ext-pecl-r3_src_install
	fi
}
