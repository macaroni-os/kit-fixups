# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod

HOMEPAGE="https://github.com/nix-community/acpi_call"
DESCRIPTION="A kernel module that enables you to call ACPI methods"
SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

CONFIG_CHECK="ACPI"
MODULE_NAMES="acpi_call(misc:${S})"
BUILD_TARGETS="default"

src_compile(){
	BUILD_PARAMS="KDIR=${KV_OUT_DIR} M=${S}"
	linux-mod_src_compile
}
