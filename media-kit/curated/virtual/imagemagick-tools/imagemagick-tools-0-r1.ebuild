# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for imagemagick command line tools"
SLOT="0"
KEYWORDS="*"
IUSE="jpeg perl png svg tiff"

# This virtual is to be used **ONLY** for depending on the runtime
# tools of imagemagick/graphicsmagick. It should and cannot be used
# for linking against, as subslots are not transitively passed on.
# For linking, you will need to depend on the respective libraries
# in all consuming ebuilds and use appropriate sub-slot operators.
# See also: https://bugs.gentoo.org/314431
RDEPEND="
	|| (
		media-gfx/imagemagick[jpeg?,perl?,png?,svg?,tiff?]
		media-gfx/graphicsmagick[imagemagick,jpeg?,perl?,png?,svg?,tiff?]
	)"
