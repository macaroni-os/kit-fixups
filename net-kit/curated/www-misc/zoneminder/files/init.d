#!/sbin/openrc-run
# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

depend() {
	use mysql
	need apache2
}

start_pre() {
	checkpath -d -m 0775 -o apache:apache /var/run/zm
	checkpath -d -m 0775 -o apache:apache /var/tmp/zm
	checkpath -d -m 0775 -o apache:apache /var/cache/zoneminder
}

start() {
	ebegin "Starting zoneminder"
	${CMD_START}
	eend $?
}

stop() {
	ebegin "Stopping zoneminder"
	${CMD_STOP}
	eend $?
}
