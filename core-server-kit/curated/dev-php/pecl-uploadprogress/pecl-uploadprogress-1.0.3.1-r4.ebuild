# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="An extension to track progress of a file upload"
LICENSE="PHP-3.01"
SLOT="0"
IUSE=""

RDEPEND="
	php_targets_php7-4? ( dev-lang/php:7.0[apache2] )
	php_targets_php7-3? ( dev-lang/php:7.1[apache2] )
	php_targets_php7-2? ( dev-lang/php:7.2[apache2] )
"
PATCHES=( "${FILESDIR}/1.0.3.1-php7.patch" )
