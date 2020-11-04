# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-build

DESCRIPTION="Virtual to select between libjpeg-turbo and IJG jpeg for source-based packages"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="|| (
		>=media-libs/libjpeg-turbo-1.5.3-r2:0[static-libs?,${MULTILIB_USEDEP}]
		>=media-libs/jpeg-9d:0[static-libs?,${MULTILIB_USEDEP}]
		)"
