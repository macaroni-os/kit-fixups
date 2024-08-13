# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit java-vm-2 toolchain-funcs

MY_PV=${PV/_p/+}
SLOT=${MY_PV%%[.+]*}

abi_uri() {
	echo "${2-$1}? (
			https://download.oracle.com/java/${SLOT}/archive/jdk-${MY_PV}_linux-${1}_bin.tar.gz
		)"
}

DESCRIPTION="Prebuilt Java JDK binaries provided by Oracle"
HOMEPAGE="https://www.oracle.com/java/technologies/downloads/"
SRC_URI="
	$(abi_uri x64 amd64)
	$(abi_uri aarch64 arm64)
"

LICENSE="Oracle-no-fee"
KEYWORDS="amd64 arm64"

IUSE="alsa cups headless-awt selinux source cacerts"

RDEPEND="
	app-eselect/eselect-java
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/harfbuzz
	>=sys-apps/baselayout-java-0.1.0-r1
	>=sys-libs/glibc-2.2.5:*
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )
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

    if use cacerts ; then
	    rm -v lib/security/cacerts || die
	    dosym ../../../../etc/ssl/certs/java/cacerts "${dest}"/lib/security/cacerts
	fi
		
	dodir "${dest}"
	cp -pPR * "${ddest}" || die
	
	if [ "${P}" != "${PN}-${SLOT}" ]; then
	    dosym "${P}" "/opt/${PN}-${SLOT}"
	fi
	
	dodir "${djavaconfig}" 

	java-vm_install-env "${FILESDIR}"/${PN}-${SLOT}.env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}
