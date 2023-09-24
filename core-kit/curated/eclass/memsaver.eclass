# Distributed under the terms of the GNU General Public License v2
#
# This eclass is useful to compile large packages like webkit. Modern build systems like ninja
# try to maximise the number of cores being used to compile. This also consumes memory on the system
# and can often lead to the kernel killing off the compile process (via OOM killer).
# This eclass limits the number of compile jobs based on available RAM and CPU cores
#
# MAINTAINERS: drobbins@funtoo.org adbosco@funtoo.org seemant@funtoo.org

EXPORT_FUNCTIONS src_configure

IUSE+="+memsaver"

: "${MEMSAVER_FACTOR:=1750000}"


memsaver_src_configure() {
	if use memsaver; then
		# set the default language so that we can parse the system properties consistently
		export LANGUAGE=C.UTF-8

		# limit number of jobs based on available memory:
		mem=$(grep ^MemTotal /proc/meminfo | awk '{print $2}')
		jobs=$((mem/MEMSAVER_FACTOR))

		# don't use more jobs than physical cores:
		if [ -e /sys/devices/system/cpu/possible ]; then
			# actual physical cores, without considering hyper-threading:
			max_parallelism="$( lscpu -p | grep -v '^#' | cut -f2 -d, | sort -u | wc -l )"
			einfo "memsaver.eclass limiting max parallelism to ${max_parallelism}"
		else
			max_parallelism=999
		fi

		if [ ${jobs} -lt 1 ]; then
			einfo "memsaver.eclass using jobs setting of 1 (limited by memory)"
			jobs=1
		elif [ ${jobs} -gt ${max_parallelism} ]; then
			einfo "memsaver.eclass using jobs setting of ${max_parallelism} (limited by physical cores)"
			jobs=${max_parallelism}
		else
			einfo "memsaver.eclass using jobs setting of ${jobs} (limited by memory)"
			jobs=${jobs}
		fi
		export MAKEOPTS="-j${jobs}"
	else
		jobs="$(makeopts_jobs)"
		einfo "Using default Portage jobs setting."
		if [ -z "${MAKEOPTS}" ]; then
			export MAKEOPTS="-j${jobs}"
		fi
	fi
}
