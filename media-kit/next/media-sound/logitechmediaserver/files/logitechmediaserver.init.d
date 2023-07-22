#!/sbin/openrc-run
# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

# These fit the Logitech Media Server ebuild and so shouldn't need to be
# changed; user-servicable parts go in /etc/conf.d/logitechmediaserver.
lms=logitechmediaserver
rundir=/run/${lms}
logdir=/var/log/${lms}
bindir=/opt/${lms}
datadir=/var/lib/${lms}
pidfile=${rundir}/${lms}.pid
cachedir=${datadir}/cache
prefsdir=${datadir}/preferences
lmsuser=${lms}
lmsbin=${bindir}/slimserver.pl

depend() {
	need net
}

start_pre() {
	checkpath -q -d -o ${lmsuser}:${lmsuser} -m 0770 "${rundir}"
}

start() {
	ebegin "Starting Logitech Media Server"

	cd /
	start-stop-daemon \
		--start --exec ${lmsbin} \
		--pidfile ${pidfile} \
		--user ${lmsuser} \
		--background \
		-- \
		--quiet \
		--pidfile=${pidfile} \
		--cachedir=${cachedir} \
		--prefsdir=${prefsdir} \
		--logdir=${logdir} \
		${LMS_OPTS}

	eend $? "Failed to start Logitech Media Server"
}

stop() {
	ebegin "Stopping Logitech Media Server"
	start-stop-daemon --retry 10 --stop --pidfile ${pidfile}
	eend $? "Failed to stop Logitech Media Server"
}
