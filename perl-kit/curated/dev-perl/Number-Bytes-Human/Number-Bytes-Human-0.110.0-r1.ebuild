# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=FERREIRA
DIST_VERSION=0.11
inherit perl-module
IUSE="test"

DESCRIPTION="Convert byte count to human readable format"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	virtual/perl-Carp
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		virtual/perl-Test-Simple
	)
"

PERL_RM_FILES=( "t/90pod.t" "t/98pod-coverage.t" )
