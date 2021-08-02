# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for ${PN#perl-}"
SLOT="0"
KEYWORDS="*"

# Check https://wiki.gentoo.org/wiki/Project:Perl/maint-notes/virtual/perl-Module-CoreList
# When bumping this package.
RDEPEND="
	|| ( =dev-lang/perl-5.32.0* ~perl-core/${PN#perl-}-${PV} )
	dev-lang/perl:=
	!<perl-core/${PN#perl-}-${PV}
	!>perl-core/${PN#perl-}-${PV}-r999
"
