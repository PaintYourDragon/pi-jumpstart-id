#! /bin/sh
### BEGIN INIT INFO
# Provides:          hostname
# Required-Start:
# Required-Stop:
# Should-Start:      glibc
# Default-Start:     S
# Default-Stop:
# Short-Description: Set hostname based on /etc/hostname and GPIO jumpers
# Description:       Read the machines hostname from /etc/hostname, poll
#                    one or more GPIO pins and update the kernel value
#                    with the combined value.  If /etc/hostname is empty,
#                    the current kernel value for hostname is used.  If
#                    the kernel value is empty, 'localhost' is used.
### END INIT INFO

PATH=/sbin:/bin:/usr/local/bin

. /lib/init/vars.sh
. /lib/lsb/init-functions

PINS="17 23 25"
PINBIT=1
HOSTIDX=0

do_start () {
	[ -f /etc/hostname ] && HOSTNAME="$(cat /etc/hostname)"

	# Keep current name if /etc/hostname is missing.
	[ -z "$HOSTNAME" ] && HOSTNAME="$(hostname)"

	# And set it to 'localhost' if no setting was found
	[ -z "$HOSTNAME" ] && HOSTNAME=localhost

	for PIN in $PINS; do
		gpio -g mode $PIN up
		if [ `gpio -g read $PIN` -eq 0 ] ; then
			HOSTIDX=$((HOSTIDX+PINBIT))
		fi
		PINBIT=$((PINBIT*2))
	done
	gpio unexportall
	HOSTNAME=$HOSTNAME$HOSTIDX

	[ "$VERBOSE" != no ] && log_action_begin_msg "Setting hostname to '$HOSTNAME'"
	sed -i 's/127.0.1.1\s.*/127.0.1.1\t'$HOSTNAME'/' /etc/hosts
	hostname "$HOSTNAME"
	ES=$?
	[ "$VERBOSE" != no ] && log_action_end_msg $ES
	exit $ES
}

do_status () {
	HOSTNAME=$(hostname)
	if [ "$HOSTNAME" ] ; then
		return 0
	else
		return 4
	fi
}

case "$1" in
  start|"")
	do_start
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	# No-op
	;;
  status)
	do_status
	exit $?
	;;
  *)
	echo "Usage: hostname.sh [start|stop]" >&2
	exit 3
	;;
esac

:
