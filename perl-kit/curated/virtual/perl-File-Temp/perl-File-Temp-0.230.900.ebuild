# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for ${PN#perl-}"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	~perl-core/${PN#perl-}-${PV}
	dev-lang/perl:=
"

# this is the dev-lang/perl-5.30 and dev-lang/perl-5.32 version but we need the security patch
