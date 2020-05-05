# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_rc/RC}"
PHP_EXT_PECL_FILENAME="yaml-${MY_PV}.tgz"
PHP_EXT_NAME="yaml"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
DOCS=( CREDITS README )


USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

S="${WORKDIR}/yaml-${MY_PV}"
PHP_EXT_S="${S}"


DESCRIPTION="YAML 1.1 (YAML Ain't Markup Language) serialization for PHP"
LICENSE="MIT"
SLOT="7"
IUSE=""

DEPEND=">=dev-libs/libyaml-0.1.0"
RDEPEND="${DEPEND}"
PHP_EXT_ECONF_ARGS=""

src_prepare() {
	if use php_targets_php7-4 || use php_targets_php7-2 || use php_targets_php7-3 ; then
		php-ext-source-r3_src_prepare
	else
		default_src_prepare
	fi
}

src_install() {
	if use php_targets_php7-4 || use php_targets_php7-2 || use php_targets_php7-3 ; then
		php-ext-pecl-r3_src_install
	fi
}
