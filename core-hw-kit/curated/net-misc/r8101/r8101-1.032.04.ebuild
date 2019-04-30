# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils linux-info toolchain-funcs linux-mod

DESCRIPTION="Driver for Realtek 810x/840x based PCI-E/PCI Ethernet Cards (PCI_ID 10ec:8136)"
HOMEPAGE="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=14&PFid=7&Level=5&Conn=4&DownTypeID=3&GetDown=false#2"
SRC_URI="http://12244.wpc.azureedge.net/8012244/drivers/rtdrivers/cn/nic/0008-r8101-1.032.04.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

MODULE_NAMES="r8101(net/ethernet::src)"
BUILD_TARGETS="modules"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_install() {
	linux-mod_src_install
}

