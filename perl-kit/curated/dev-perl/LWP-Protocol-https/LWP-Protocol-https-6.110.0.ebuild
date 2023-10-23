# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=OALDERS
DIST_VERSION=6.11
inherit perl-module

DESCRIPTION="Provide https support for LWP::UserAgent"

SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	>=dev-perl/IO-Socket-SSL-1.970.0
	>=dev-perl/libwww-perl-6.60.0
	>=dev-perl/Net-HTTP-6
"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		>=dev-perl/Test-Needs-0.2.10
		virtual/perl-Test-Simple
		dev-perl/Test-RequiresInternet
	)
"
