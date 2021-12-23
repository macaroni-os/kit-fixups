# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit java-vm-2 toolchain-funcs

abi_uri() {
	echo "${2-$1}? (
			https://github.com/adoptium/temurin${SLOT}-binaries/releases/download/jdk-${MY_PV}/OpenJDK${SLOT}U-jdk_${1}_linux_hotspot_${MY_PV//+/_}.tar.gz
		)"
}

MY_PV=${PV/_p/+}
SLOT=${MY_PV%%[.+]*}

DESCRIPTION="Prebuilt Java JDK binaries provided by Eclipse Temurin"
HOMEPAGE="https://adoptium.net"
SRC_URI="
	$(abi_uri aarch64 arm64)
	$(abi_uri arm)
	$(abi_uri ppc64le ppc64)
	$(abi_uri x64 amd64)
"

LICENSE="GPL-2-with-classpath-exception"
KEYWORDS="amd64 ~arm arm64 ppc64"

IUSE="alsa cups headless-awt selinux source"

RDEPEND="
	app-eselect/eselect-java
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/harfbuzz
	>=sys-apps/baselayout-java-0.1.0-r1
	>=sys-libs/glibc-2.2.5:*
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )
	arm? ( dev-libs/libffi-compat:6 )
	cups? ( net-print/cups )
	selinux? ( sec-policy/selinux-java )
	!headless-awt? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	)
"

RESTRICT="preserve-libs strip"
QA_PREBUILT="*"

S="${WORKDIR}/jdk-${MY_PV}"

src_unpack() {
	default
	# 753575
	if use arm; then
		mv -v "${S}"* "${S}" || die
	fi
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED%/}/${dest#/}"
	local djavaconfig="/etc/java-config-2"

	if use headless-awt ; then
		rm -v lib/lib*{[jx]awt,splashscreen}* || die
	fi

	if ! use source ; then
		rm -v lib/src.zip || die
	fi

	rm -v lib/security/cacerts || die
	dosym ../../../../etc/ssl/certs/java/cacerts \
		"${dest}"/lib/security/cacerts
		
	dodir "${dest}"
	cp -pPR * "${ddest}" || die
	
	dosym "${P}" "/opt/${PN}-${SLOT}"
	
	dodir "${djavaconfig}" 

	java-vm_install-env "${FILESDIR}"/${PN}-${SLOT}.env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}
