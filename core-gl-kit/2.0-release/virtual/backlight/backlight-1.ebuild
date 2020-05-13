# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A virtual for backlight ebuilds."
SLOT="0"
KEYWORDS="*"
IUSE="acpi"

RDEPEND="acpi? ( sys-power/acpilight ) !acpi? ( x11-apps/xbacklight )"
