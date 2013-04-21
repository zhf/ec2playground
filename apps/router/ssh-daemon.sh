DIR=`dirname $0`
DEBUG="NO"
LOG_FILE=$DIR/daemon.log
source $DIR/tunnel.cfg

log()
{
    [ "$LOG" == "YES" ] && printf "`date`\t $* \n" >> $LOG_FILE
    [ "$VERBOSE" == "YES" ] && [ -t 1 ] && printf "`date`\t $* \n"
}

log2()
{
	[ "$DEBUG" == "YES" ] && log $*
}

wait_for_new_tunnel()
{
	local t=30
	log "Waiting $t secs for launching new ssh process and re-establishing tunnel"
	sleep $t
}

check_host_alive()
{
	source $DIR/current.profile
	# Default SSH port reachable?
	netcat -z -w 5 $AWS_HOST $SSH_PORT
	# Try again with standard SSH port
	if test $? -ne 0; then
		sleep 10
		netcat -z -w 5 $AWS_HOST 22
		# One more attempt, response to ping?
		if test $? -ne 0; then
			sleep 10
			fping "$AWS_HOST" >/dev/null
		fi		
	fi

	return $?
}

while getopts 'vwl' OPTION
do
	case $OPTION in
		v) VERBOSE="YES"
			;;
		w) WAIT="YES"
			;;
		l) LOG="YES"
			;;
		*) echo "Unknown options."
			exit 1
			;;
	esac
done
shift $(($OPTIND - 1))

log "Starting tunnel daemon."

if [ "$WAIT" == "YES" ]; then
	wait_for_new_tunnel
fi

while true
do
	local tunnel_status=`$DIR/fq.sh status`
	case $tunnel_status in
		DELETED)
			log "Profile is gone. Terminating daemon."
			break
			;;
		CLOSED)	
			log "SSH is not running."
			
			check_host_alive

			if test $? -eq 0; then
				log "Server in profile is still up. Re-establishing tunnel."
				$DIR/fq.sh tunnel
				wait_for_new_tunnel
			else
				log "Server in profile is down. Terminating daemon."
				break
			fi
			;;
		ZOMBIE)
			log "SSH is running but proxy is not listening (ZOMBIE). Resetting tunnel."
			$DIR/fq.sh force_kill
			sleep 1
			$DIR/fq.sh tunnel

			wait_for_new_tunnel
			;;
		LISTENING)	
			log2 "Proxy is listening. Everything seems fine now. Check again later."
			sleep 10
			;;
		*)
			log "Unknown status."
			exit 1
			;;
	esac
done
