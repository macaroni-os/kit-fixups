EAPI="6"
PYTHON_COMPAT=( python2_7 )

inherit eutils python-any-r1

# Many thanks to https://github.com/mausys for this ebuild

DESCRIPTION="GN is a meta-build system that generates Ninja build files"
HOMEPAGE="https://chromium.googlesource.com/chromium/src/+/master/tools/gn"

LICENSE="BSD"
KEYWORDS=""
IUSE=""
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-util/ninja"

GTEST_VERSION="1.8.0"

SRC_URI="http://distfiles.gentoo.org/distfiles/gtest-${GTEST_VERSION}.tar.gz
	https://chromium.googlesource.com/chromium/src/+archive/${PV}/tools/gn.tar.gz -> ${P}-gn.tar.gz
	https://chromium.googlesource.com/chromium/src/+archive/${PV}/build.tar.gz -> ${P}-build.tar.gz
	https://chromium.googlesource.com/chromium/src/+archive/${PV}/base.tar.gz -> ${P}-base.tar.gz
	https://chromium.googlesource.com/chromium/src/+archive/${PV}/build_overrides.tar.gz -> ${P}-build_overrides.tar.gz" 

src_unpack() {
	mkdir -p ${S}/tools/gn 
	cd  ${S}/tools/gn 
	unpack ${P}-gn.tar.gz
	
	mkdir -p ${S}/third_party/googletest
	cd ${S}/third_party/googletest
	unpack gtest-${GTEST_VERSION}.tar.gz
	
	mkdir -p ${S}/base
	cd ${S}/base
	unpack ${P}-base.tar.gz
	
	mkdir -p ${S}/build
	cd ${S}/build
	unpack ${P}-build.tar.gz
	
	mkdir -p ${S}/build_overrides
	cd ${S}/build_overrides
	unpack ${P}-build_overrides.tar.gz
}

src_prepare() {
	mkdir -p ${S}/testing
	cd ${S}/testing
	ln -s ../third_party/googletest/googletest-release-${GTEST_VERSION}/googletest gtest
	ln -s ../third_party/googletest/googletest-release-${GTEST_VERSION}/googlemock gmock
	default
}

src_compile() {
	mkdir ${WORKDIR}/build
	cd ${S}/tools/gn
	echo "${PYTHON}"
	echo $(pwd)
	"${PYTHON}" bootstrap/bootstrap.py -s -v -o  ${WORKDIR}/build 
}


src_install() {
	dobin ${WORKDIR}/build/gn
}
