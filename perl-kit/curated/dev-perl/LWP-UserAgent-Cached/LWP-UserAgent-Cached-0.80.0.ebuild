# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=OLEG
DIST_VERSION=0.08
inherit perl-module

DESCRIPTION="LWP::UserAgent with simple caching mechanism"

SLOT="0"
KEYWORDS="*"


IUSE="test"

RDEPEND="
	dev-perl/libwww-perl
"
BDEPEND="${RDEPEND}
	virtual/perl-File-Temp
	>=virtual/perl-ExtUtils-MakeMaker-6.520.0
	test? (
		>=dev-perl/Test-Mock-LWP-Dispatch-0.20.0
		>=virtual/perl-Test-Simple-0.880.0
	)
"
