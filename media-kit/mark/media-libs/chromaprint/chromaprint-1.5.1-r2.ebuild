# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Library implementing a custom algorithm for extracting audio fingerprints"
HOMEPAGE="https://acoustid.org/chromaprint"
SRC_URI="https://github.com/acoustid/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/1"
KEYWORDS="*"
IUSE="tools"

# Default to fftw to avoid awkward circular dependency w/ ffmpeg
# See bug #833821 for an example
RDEPEND="tools? ( media-video/ffmpeg:= )
	!tools? ( sci-libs/fftw:= )"
DEPEND="${RDEPEND}"

DOCS=( NEWS.txt README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=False

		-DBUILD_TOOLS=$(usex tools)
		-DFFT_LIB=$(usex tools 'avfft' 'fftw3')
		$(usex tools '-DAUDIO_PROCESSOR_LIB=swresample' '')
		# Automagicallyish looks for ffmpeg, but there's no point
		# even doing the check unless we're building with tools
		# (=> without fftw3, and with ffmpeg).
		-DCMAKE_DISABLE_FIND_PACKAGE_FFmpeg=$(usex !tools)
	)

	cmake_src_configure
}

