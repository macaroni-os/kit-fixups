# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Linux kernel sources"
SLOT="0"
KEYWORDS="*"
IUSE="firmware"

RDEPEND="
	firmware? ( sys-kernel/linux-firmware )
	|| (
		sys-kernel/dummy-sources
		sys-kernel/debian-sources
		sys-kernel/debian-sources-lts
		sys-kernel/gentoo-sources
		sys-kernel/ck-sources
		sys-kernel/vanilla-sources
	)"
