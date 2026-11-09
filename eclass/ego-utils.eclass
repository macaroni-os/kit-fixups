# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ego-utils.eclass
# @BLURB: Auxiliary functions for integrating ego profile in ebuilds.
# @DESCRIPTION:

# @FUNCTION: ego_mixin_check
# @DESCRIPTION:
# Tests for and dies if a specific mix-in is not set in the current ego profile.
ego_mixin_check() {
	for mix_in in $(ROOT="${ROOT}/" ego profile get mix-ins); do
		[[ "${mix_in}" == "${1}" ]] && return
	done
	ewarn
	ewarn "Please enable the \"${1}\" mix-in in your ego profile first."
	ewarn
	die "\"${1}\" mix-in not enabled in current ego profile."
}
