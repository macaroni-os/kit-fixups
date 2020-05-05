# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="RRDtool bindings for PHP"
LICENSE="BSD"
SLOT="7"

DEPEND="
	php_targets_php7-2? ( net-analyzer/rrdtool[graph] )
	php_targets_php7-3? ( net-analyzer/rrdtool[graph] )
	php_targets_php7-4? ( net-analyzer/rrdtool[graph] )
"
RDEPEND="${DEPEND}"

src_prepare() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-source-r3_src_prepare
	else
		default
	fi
}

src_configure() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		local PHP_EXT_ECONF_ARGS=()
		php-ext-source-r3_src_configure
	fi
}

src_install() {
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		php-ext-pecl-r3_src_install
	fi
}

src_test() {
	local slot
	if use php_targets_php7-2 || use php_targets_php7-3 || use php_targets_php7-4 ; then
		for slot in $(php_get_slots); do
			php_init_slot_env "${slot}"
			# Prepare test data
			emake -C tests/data all
			NO_INTERACTION="yes" emake test
		done
	fi
}
