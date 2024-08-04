# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Whip tool catalog"
HOMEPAGE="https://github.com/macaroni-os/whip-catalog"
EGIT_REPO_URI="https://github.com/macaroni-os/whip-catalog"
EGIT_COMMIT="cf9a2ff03c548e8f65504c643bd3b38bf467f083"

RESTRICT="network-sandbox"
RDEPEND="app-admin/whip"
IUSE=""
SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="*"

src_install() {
	insinto /usr/share/macaroni/whip-catalog/eclass
	for f in "${WORKDIR}"/catalog/eclass/*.yaml ; do
		doins "${f}"
	done
	insinto /usr/share/macaroni/whip-catalog/commons
	for f in "${WORKDIR}"/catalog/commons/*.yaml ; do
		doins "${f}"
	done
}
