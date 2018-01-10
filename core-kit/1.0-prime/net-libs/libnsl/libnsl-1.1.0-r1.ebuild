# Distributed under the terms of the GNU General Public License v2

EAPI=6

# this is workaround ebuild to sort dependency block introduced with gentoo glib'c unofficial library split (libnsl is a split of glibc's libnsl). Not applicable to Funtoo.
# https://github.com/thkukuk/libnsl
# https://bugs.funtoo.org/browse/FL-4436

DESCRIPTION="A dummy ebuild for the glibc's libnsl"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} sys-libs/glibc"
