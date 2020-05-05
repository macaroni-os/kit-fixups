# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PHP_EXT_NAME="timezonedb"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="Timezone Database to be used with PHP's date and time functions"
LICENSE="PHP-3"
SLOT="0"
IUSE=""
PHP_EXT_ECONF_ARGS=""
