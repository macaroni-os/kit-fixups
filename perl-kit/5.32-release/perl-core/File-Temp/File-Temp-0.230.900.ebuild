# Distributed under the terms of the GNU General Public License v2

EAPI=6

DIST_AUTHOR=ETHER
DIST_VERSION=0.2309
inherit perl-module

DESCRIPTION="File::Temp can be used to create and open temporary files in a safe way"

SLOT="0"
KEYWORDS="*"
IUSE=""

# bug 390719
PATCHES=( "${FILESDIR}/${PN}-0.230.0-symlink-safety.patch" )
