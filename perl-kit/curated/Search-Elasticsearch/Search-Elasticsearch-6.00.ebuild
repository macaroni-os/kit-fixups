# Distributed under the terms of the GNU General Public License v2

EAPI=5

MODULE_AUTHOR="DRTECH"
MODULE_VERSION="6.00"


inherit perl-module

DESCRIPTION="The official client for Elasticsearch"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="alpha amd64 amd64-fbsd arm arm64 hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 x86-fbsd   ppc-aix amd64-linux arm-linux arm64-linux ppc64-linux x86-linux ppc-macos x86-macos x64-macos m68k-mint sparc-solaris sparc64-solaris x64-solaris x86-solaris x86-winnt x64-cygwin x86-cygwin"
IUSE=""

DEPEND="dev-perl/namespace-clean
	dev-perl/HTTP-Message
	dev-perl/Moo
	dev-perl/Try-Tiny
	dev-perl/JSON-MaybeXS
	>=dev-perl/Package-Stash-0.370.0
	dev-perl/Sub-Exporter
	dev-perl/IO-Socket-SSL
	dev-perl/Any-URI-Escape
	dev-perl/Test-Deep
	dev-perl/Test-Exception
	>=dev-perl/Log-Any-Adapter-Callback-0.09
	dev-perl/URI
	dev-perl/libwww-perl
	dev-perl/Log-Any
	dev-perl/Devel-GlobalDestruction
	dev-perl/Module-Runtime
	dev-perl/Test-SharedFork
	dev-lang/perl"
