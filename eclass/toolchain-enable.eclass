#!/bin/bash
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: toolchain-enable.eclass
# @MAINTAINER:
# drobbins@funtoo.org
# @AUTHOR:
# drobbins@funtooo.org
# @BLURB: 
# @DESCRIPTION:
# Contains scripts for auto-enabling newer versions of compilers.

compiler_auto_enable() {

	# Here, we will auto-enable the new compiler if none is currently enabled, or
	# if this is an _._.x upgrade to an already-installed compiler.

	# call with first arg being the new version installed, second arg ctarget

	local do_config="no"
	local new_gcc_ver="$1"
	local ctarget="$2"
	curr_gcc_config=$(env -i ROOT="${ROOT}" gcc-config -c ${ctarget} 2>/dev/null)
	if [ -n "${curr_gcc_config}" ]; then
		IFS='.' read -r -a previous_arr <<< "$(gcc-config -S ${curr_gcc_config} | awk '{print $2}')"
		IFS='.' read -r -a new_arr <<< "${new_gcc_ver}"
		if [ ${new_arr[0]} -gt ${previous_arr[0]} ]; then
			do_config="yes"
		elif [ ${new_arr[0]} -eq ${previous_arr[0]} ]; then
			if [ ${new_arr[1]} -gt ${previous_arr[1]} ]; then
				do_config="yes"
			elif [ ${new_arr[1]} -eq ${previous_arr[1]} ]; then
				if [ ${new_arr[2]} -gt ${previous_arr[2]} ]; then
					do_config="yes"
				fi
			fi
		fi
	fi
		
	if [ "$do_config" == "yes" ]; then
		einfo "Auto-enabling ${new_gcc_ver}..."
		gcc-config ${ctarget}-${new_gcc_ver}
	else
		einfo "This does not appear to be a regular upgrade of gcc, so"
		einfo "gcc ${new_gcc_ver} will not be automatically enabled as the"
		einfo "default system compiler."
		echo
		einfo "If you would like to make ${new_gcc_ver} the default system"
		einfo "compiler, then perform the following steps as root:"
		echo
		einfo "gcc-config ${ctarget}-${new_gcc_ver}"
		einfo "source /etc/profile"
		echo
	fi
}

