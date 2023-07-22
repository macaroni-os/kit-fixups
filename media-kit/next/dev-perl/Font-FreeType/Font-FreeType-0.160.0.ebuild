# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=DMOL
DIST_VERSION=0.16
inherit perl-module

DESCRIPTION="read font files and render glyphs from Perl using FreeType2"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris ~arm ~ppc"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-perl/Devel-CheckLib
	dev-perl/File-Which
	virtual/perl-ExtUtils-MakeMaker
	test? (
		dev-perl/Test-Warn
	)
"

RDEPEND="media-libs/freetype"

src_compile() {
	mymake=(
		"OPTIMIZE=${CFLAGS}"
	)
	perl-module_src_compile
}
