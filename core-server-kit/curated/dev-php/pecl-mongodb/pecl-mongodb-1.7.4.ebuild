# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PHP_EXT_NAME="mongodb"
DOCS="README.md"

USE_PHP="php7-4 php7-2 php7-3"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="MongoDB driver for PHP"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="dev-lang/php"
RDEPEND="${DEPEND}"
