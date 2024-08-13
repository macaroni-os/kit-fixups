# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=AUDREYT
DIST_VERSION=1.05
inherit perl-module

DESCRIPTION="bidirectional Hebrew support for Perl"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris ~arm ~ppc"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-perl/Module-Install
	virtual/perl-ExtUtils-MakeMaker
	test? (
		dev-perl/Test-Warn
	)
"

PATCHES=( "${FILESDIR}/fix_incompatible_implicit_declaration_of_exit_function.patch" )


src_compile() {
	mymake=(
		"OPTIMIZE=${CFLAGS}"
	)
	perl-module_src_compile
}
