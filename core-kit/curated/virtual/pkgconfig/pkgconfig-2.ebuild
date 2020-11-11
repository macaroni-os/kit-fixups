# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for the pkg-config implementation"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	|| (
		>=dev-util/pkgconf-1.3.7[pkg-config]
		>=dev-util/pkgconfig-0.29.2
		>=dev-util/pkgconfig-openbsd-20130507-r2[pkg-config]
	)"

