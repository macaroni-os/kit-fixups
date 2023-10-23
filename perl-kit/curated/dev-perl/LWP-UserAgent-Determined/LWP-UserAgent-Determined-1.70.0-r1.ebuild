# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=ALEXMV
DIST_VERSION=1.07
inherit perl-module

DESCRIPTION="A virtual browser that retries errors"

SLOT="0"
KEYWORDS="*"

RDEPEND="dev-perl/libwww-perl"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"
