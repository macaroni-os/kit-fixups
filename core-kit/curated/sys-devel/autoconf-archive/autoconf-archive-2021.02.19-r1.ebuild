# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="GNU Autoconf Macro Archive"
HOMEPAGE="https://www.gnu.org/software/autoconf-archive/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

PATCHES=(
	"${FILESDIR}"/${PN}-2021.02.19-python310.patch
	"${FILESDIR}"/${PN}-2021.02.19-revert-ax_pthreads.patch
)
