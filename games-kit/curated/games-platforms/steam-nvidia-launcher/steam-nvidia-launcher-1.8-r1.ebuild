# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Funtoo's Docker-based Steam environment for NVIDIA systems (deprecated)."
HOMEPAGE="https://www.funtoo.org/Steam"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

pkg_postinst() {
	ewarn
	ewarn "Funtoo's Docker-based Steam container is getting deprecated in favor of Flatpak."
	ewarn
	ewarn "Please visit https://www.funtoo.org/Steam for steps on how to configure your system."
	ewarn
}
