# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit linux-info toolchain-funcs

# Find updates by searching and clicking the first link (hopefully it's the one):
# https://www.intel.com/content/www/us/en/search.html?keyword=Processor+Microcode+Data+File

COLLECTION_SNAPSHOT="20180808"
INTEL_SNAPSHOT="20180807"
NUM="28087"
DESCRIPTION="Intel IA32/IA64 microcode update data"
HOMEPAGE="http://inertiawar.com/microcode/ https://downloadcenter.intel.com/Detail_Desc.aspx?DwnldID=${NUM}"
SRC_URI="https://downloadmirror.intel.com/${NUM}/eng/microcode-${INTEL_SNAPSHOT}.tgz
	https://dev.gentoo.org/~whissi/dist/intel-microcode/intel-microcode-collection-${COLLECTION_SNAPSHOT}.tar.xz"

LICENSE="intel-ucode"
SLOT="0"
KEYWORDS=""
IUSE="+split-ucode vanilla"
DEPEND="sys-apps/iucode_tool"

# !<sys-apps/microcode-ctl-1.17-r2 due to bug #268586
RDEPEND="!<sys-apps/microcode-ctl-1.17-r2
>=app-admin/ego-2.5.0.4"

RESTRICT="binchecks strip"

S=${WORKDIR}

# Blacklist bad microcode here.
# 0x000406f1 aka 06-4f-01 aka CPUID 406F1 require newer microcode loader
MICROCODE_BLACKLIST_DEFAULT="-s !0x000406f1"
MICROCODE_BLACKLIST="${MICROCODE_BLACKLIST:=${MICROCODE_BLACKLIST_DEFAULT}}"

# In case we want to set some defaults ...
MICROCODE_SIGNATURES_DEFAULT=""

# Advanced users only:
# merge with:
# only current CPU: MICROCODE_SIGNATURES="-S"
# only specific CPU: MICROCODE_SIGNATURES="-s 0x00000f4a -s 0x00010676"
# exclude specific CPU: MICROCODE_SIGNATURES="-s !0x00000686"
MICROCODE_SIGNATURES="${MICROCODE_SIGNATURES:=${MICROCODE_SIGNATURES_DEFAULT}}"

pkg_pretend() {
	if [[ "${MICROCODE_BLACKLIST}" != "${MICROCODE_BLACKLIST_DEFAULT}" ]]; then
		ewarn "MICROCODE_BLACKLIST is set to \"${MICROCODE_BLACKLIST}\" instead of default \"${MICROCODE_BLACKLIST_DEFAULT}\". You are on your own!"
	fi

	if [[ "${MICROCODE_SIGNATURES}" != "${MICROCODE_SIGNATURES_DEFAULT}" ]]; then
		ewarn "The user has opted in for advanced use:"
		ewarn "MICROCODE_SIGNATURES is set to \"${MICROCODE_SIGNATURES}\" instead of default \"${MICROCODE_SIGNATURES_DEFAULT}\"!"
	fi
}

src_prepare() {
	default

	# Prevent "invalid file format" errors from iucode_tool
	rm -f "${S}"/intel-ucod*/list || die
}

src_install() {
	# This will take ALL of the upstream microcode sources:
	# - microcode.dat
	# - intel-ucode/
	# In some cases, they have not contained the same content (eg the directory has newer stuff).
	MICROCODE_SRC=(
		"${S}"/intel-ucode/
		"${S}"/intel-ucode-with-caveats/
	)

	# Allow users who are scared about microcode updates not included in Intel's official
	# microcode tarball to opt-out and comply with Intel marketing
	if ! use vanilla; then
		MICROCODE_SRC+=( "${S}"/intel-microcode-collection-${COLLECTION_SNAPSHOT} )
	fi

	opts=(
		${MICROCODE_BLACKLIST}
		${MICROCODE_SIGNATURES}
		# be strict about what we are doing
		--overwrite
		--strict-checks
		--no-ignore-broken
		# we want to install latest version
		--no-downgrade
		# show everything we find
		--list-all
		# show what we selected
		--list
	)

	# split location (we use a temporary location so that we are able
	# to re-run iucode_tool in pkg_preinst; use keepdir instead of dodir to carry
	# this folder to pkg_preinst to avoid an error even if no microcode was selected):
	keepdir /tmp/intel-ucode && opts+=( --write-firmware="${ED%/}"/tmp/intel-ucode )

	iucode_tool \
		"${opts[@]}" \
		"${MICROCODE_SRC[@]}" \
		|| die "iucode_tool ${opts[@]} ${MICROCODE_SRC[@]}"

	dodoc releasenote
}

pkg_preinst() {
	if use split-ucode; then
		# Temporary /tmp/intel-ucode will become final /lib/firmware/intel-ucode ...
		dodir /lib/firmware
		mv "${ED%/}/tmp/intel-ucode" "${ED%/}/lib/firmware" || die "Failed to install splitted ucodes!"
	fi

	# Cleanup any temporary leftovers so that we don't merge any
	# unneeded files on disk
	rm -r "${ED%/}/tmp" || die "Failed to cleanup '${ED%/}/tmp'"
}

pkg_postinst() {
	if [ "$ROOT" = "/" ]; then
		/usr/bin/ego boot microcode || die
	fi

	# We cannot give detailed information if user is affected or not:
	# If MICROCODE_BLACKLIST wasn't modified, user can still use MICROCODE_SIGNATURES
	# to to force a specific, otherwise blacklisted, microcode. So we
	# only show a generic warning based on running kernel version:
	if kernel_is -lt 4 14 34; then
		ewarn "${P} contains microcode updates which require"
		ewarn "additional kernel patches which aren't yet included in kernel <4.14.34."
		ewarn "Loading such a microcode through kernel interface from an unpatched kernel"
		ewarn "can crash your system!"
		ewarn ""
		ewarn "Those microcodes are blacklisted per default. However, if you have altered"
		ewarn "MICROCODE_BLACKLIST or MICROCODE_SIGNATURES, you maybe have unintentionally"
		ewarn "re-enabled those microcodes...!"
		ewarn ""
		ewarn "Check \"${EROOT%/}/usr/share/doc/${PN}-*/releasenot*\" if your microcode update"
		ewarn "requires additional kernel patches or not."
	fi
}
