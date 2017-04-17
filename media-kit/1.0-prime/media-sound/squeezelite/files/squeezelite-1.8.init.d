#!/sbin/openrc-run

depend() {
	need net
	use alsasound
	after bootmisc
}

start() {
	ebegin "Starting squeezelite"
	start-stop-daemon \
	--start \
	--exec /usr/bin/squeezelite \
	--pidfile /run/squeezelite.pid \
	--make-pidfile \
	--background \
	-- ${SL_OPTS}
	eend $?
}

stop() {
	ebegin "Stopping squeezelite"
	start-stop-daemon \
	--stop \
	--exec /usr/bin/squeezelite \
	--pidfile /run/squeezelite.pid
	eend $?
}
