# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron.eclass
# @MAINTAINER:
# Tsvetomir Bonev <funtoo@invak.id>
# @AUTHOR:
# Tsvetomir Bonev <funtoo@invak.id>
# @BLURB: Utility eclass for Electron packages
# @DESCRIPTION:
# A utility eclass providing functions to deal with the details of installing
# Electron packages. It automatically locates installed Electron binaries that
# require specific permissions to work properly and sets them accordingly.

if [[ -z ${_ELECTRON_ECLASS} ]]; then
_ELECTRON_ECLASS=1

electron_post_src_install() {
	local electron_filepath

	find "${ED}" \
		\( -name 'chrome-sandbox' -o -name 'chrome_crashpad_handler' \) \
		-print0 |
		while IFS= read -r -d '' electron_filepath; do
			electron_filepath="${electron_filepath#"${ED}"}"
			einfo "Setting permissions for Electron binary ${electron_filepath}"

			fperms 4755 "${electron_filepath}"
		done
}

EXPORT_FUNCTIONS post_src_install
fi
