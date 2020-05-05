# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PHP_EXT_NAME="ps"

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="PHP extension for creating PostScript files"
LICENSE="BSD"
SLOT="7"
IUSE="examples"

DEPEND="
	php_targets_php7-2? ( dev-libs/pslib )
	php_targets_php7-3? ( dev-libs/pslib )
	php_targets_php7-4? ( dev-libs/pslib )
"
RDEPEND="${DEPEND}"
PHP_EXT_ECONF_ARGS=""

src_prepare() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-source-r3_src_prepare
	else
		default_src_prepare
	fi
}

src_install() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-pecl-r3_src_install
	fi
}
