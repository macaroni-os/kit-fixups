# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

USE_PHP="php7-2 php7-3 php7-4"

inherit php-ext-pecl-r3

# However, we only really build for 7.x; so redefine it here

KEYWORDS="*"

DESCRIPTION="dBase database file access functions"
LICENSE="PHP-3.01"
SLOT="7"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-source-r3_src_prepare
	else
		eapply_user
	fi
}

src_configure() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		local PHP_EXT_ECONF_ARGS=( )
		php-ext-source-r3_src_configure
	fi
}

src_install() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-pecl-r3_src_install
	fi
}
