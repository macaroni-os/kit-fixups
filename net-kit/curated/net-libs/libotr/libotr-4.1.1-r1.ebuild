# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="(OTR) Messaging allows you to have private conversations over instant messaging"
HOMEPAGE="https://otr.cypherpunks.ca"
SRC_URI="https://otr.cypherpunks.ca/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=dev-libs/libgcrypt-1.2:0
	dev-libs/libgpg-error"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS ChangeLog NEWS README UPGRADING )

src_prepare() {
	default
	sed -i -e \
		'/^#include <syscall.h>/a #include <sys/socket.h>' \
		./tests/regression/client/client.c \
		|| die
}
