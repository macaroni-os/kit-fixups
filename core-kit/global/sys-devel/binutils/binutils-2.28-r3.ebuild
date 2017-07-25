# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCHVER="1.2"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="*"

pkg_postinst() {
toolchain-binutils_pkg_postinst
# Older ebuild  were not using toolchain-binutils.eclass which has upgrade code in toolchain-binutils_pkg_postrm(), and upon removal of older binutils, profile is broken. perform upgrade here# FL-3963.
local current_profile=$(binutils-config -c ${CTARGET})
	if [[ ${current_profile} =~ ^${CTARGET}-2\.([0-9]|1[0-9]|2[0-7])($|\.) ]]; then
		binutils-config ${CTARGET}-${BVER}
	fi
}

