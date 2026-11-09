# Distributed under the terms of the GNU General Public License v2
#
# This eclass is useful for packages, which mess with boot-related things.
#
# If /etc/boot.conf is present, then this eclass will update the bootloader
# configuration by running `ego boot update`. This is necessary to ensure the
# system is in a consistent and bootable state after package installations and
# removals.
#
# MAINTAINER: invakid404@riseup.net

inherit mount-boot

EXPORT_FUNCTIONS pkg_preinst pkg_postinst pkg_prerm pkg_postrm

ego_boot_update() {
	if [[ -n ${DONT_MOUNT_BOOT} ]] ; then
		return
	fi

	if [ -e /etc/boot.conf ]; then
		ROOT=/ ego boot update
	fi
}

ego_pkg_preinst() {
	mount-boot_pkg_preinst
}

ego_pkg_postinst() {
	ego_boot_update

	mount-boot_pkg_postinst
}

ego_pkg_prerm() {
	mount-boot_pkg_prerm
}

ego_pkg_postrm() {
	ego_boot_update

	mount-boot_pkg_postrm
}
