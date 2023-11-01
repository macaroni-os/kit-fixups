# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=SULLR
DIST_VERSION=2.083
DIST_EXAMPLES=("example/*")
inherit perl-module

DESCRIPTION="Nearly transparent SSL encapsulation for IO::Socket::INET"

SLOT="0"
KEYWORDS="*"
IUSE="idn"

RDEPEND="
	dev-perl/Mozilla-CA
	>=dev-perl/Net-SSLeay-1.460.0
	virtual/perl-Scalar-List-Utils
	idn? (
		|| (
			>=dev-perl/URI-1.50
			dev-perl/Net-LibIDN
			dev-perl/Net-IDN-Encode
		)
	)"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"

PATCHES=(
	"${FILESDIR}/${PV}-openssl-compat.patch"
)

mydoc=("docs/debugging.txt")
