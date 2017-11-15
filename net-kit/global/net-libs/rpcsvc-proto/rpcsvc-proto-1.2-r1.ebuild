# Distributed under the terms of the GNU  General Public License v2

EAPI=6

# this is workaround ebuild to sort dependency block introduced with gentoo glib'c unofficial library split (rpcsvcp-proto is a split of SunRPC). Not applicable to Funtoo.
# https://github.com/thkukuk/rpcsvc-proto
# https://bugs.funtoo.org/browse/FL-4432

DESCRIPTION="dummy ebuild for glib's SunRPC"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} sys-libs/glibc"
