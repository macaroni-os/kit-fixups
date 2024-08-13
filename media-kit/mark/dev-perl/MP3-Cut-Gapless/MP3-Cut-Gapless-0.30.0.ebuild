# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=AGRUNDMA
DIST_VERSION=0.03
inherit perl-module

DESCRIPTION="Port of pcutmp3 to Perl with improvements"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris ~arm ~ppc"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/perl-ExtUtils-MakeMaker
	dev-perl/Module-Install
	test? (
		dev-perl/Test-Warn
	)
"
PERL_RM_FILES=(
	"t/04critic.t"
)

src_compile() {
	mymake=(
		"OPTIMIZE=${CFLAGS}"
	)
	perl-module_src_compile
}
