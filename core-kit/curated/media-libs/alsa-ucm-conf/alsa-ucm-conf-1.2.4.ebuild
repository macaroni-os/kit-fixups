# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="ALSA ucm configuration files"
HOMEPAGE="https://www.alsa-project.org"
SRC_URI="https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-1.2.4.tar.bz2"
LICENSE="BSD"
SLOT="0"

KEYWORDS="*"
IUSE=""

RDEPEND="!<media-libs/alsa-lib-1.2.1"
DEPEND="${RDEPEND}"

src_install() {
	insinto /usr/share/alsa
	doins -r ucm{,2}
}