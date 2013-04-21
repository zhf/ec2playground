# Path for opkg version of ssh
. /tmp/root/.profile
DIR=`dirname $0`
PROFILE=$DIR/current.profile
. $DIR/tunnel.cfg

DEFAULT_USER="tunnel"
DEFAULT_CERT="zava_rsa.pub"

nag()
{
    printf " * `basename $0`:\033[01;36m $* \033[00m\n"
}

save_profile()
{
    local key=$1
    local val=$2
    sed -e "s/^$key=.*/$key=\'$val\'/" -i $PROFILE
}

stop()
{
    test -z "`pidof ssh`" && return 1

    nag "Existing tunnel:"
    test -z "$AWS_HOST" && source $PROFILE
    printf "\033[07;36m %s in %s since %s \n\033[00m" "$AWS_HOST" "$AWS_ZONE" "$AWS_DATE"
    printf "Stop it? (Y/n)" 
    read
    if test "$REPLY" != "n"; then
		force_kill
    fi
}

kill_daemon()
{
	local daemon_pid=`ps | grep ssh-daemon | grep -v grep | awk '{print $1}'`
	test -n "$daemon_pid" && kill -9 $daemon_pid && nag "Daemon with pid $daemon_pid killed."
}

kill_tunnel()
{
	killall ssh && nag "Tunnel killed."
}

force_kill()
{
	kill_daemon
	sleep 1
	kill_tunnel
	sleep 1
}	

empty()
{
    save_profile "AWS_HOST" ''
    save_profile "AWS_USER" ''
    save_profile "AWS_CERT" ''
    save_profile "AWS_ZONE" ''
    save_profile "AWS_DATE" ''
    unset $AWS_HOST
    unset $AWS_USER
    unset $AWS_CERT
    unset $AWS_ZONE
    unset $AWS_DATE
}

delete()
{
    test -z "$AWS_HOST" && source $PROFILE
    test -n "$1" && test "$AWS_HOST" != "$1" && exit 2
    stop
    empty
    nag "Tunnel deleted."
}

tunnel()
{
    stop
    if test -z "$1"; then
		. $PROFILE
    else
		AWS_HOST=$3
		AWS_USER=$2
		AWS_CERT=$1
		AWS_ZONE=$4
		save_profile "AWS_HOST" "$AWS_HOST"
		save_profile "AWS_USER" "$AWS_USER"
		save_profile "AWS_CERT" "$AWS_CERT" 
		save_profile "AWS_ZONE" "$AWS_ZONE" 
		save_profile "AWS_DATE" "`date`"
    fi
	test "_" == "$AWS_USER" && AWS_USER=$DEFAULT_USER
	test "_" == "$AWS_CERT" && AWS_CERT=$DEFAULT_CERT
    local lan=192.168.1.1:$SOCKS5_PORT
	# Using zava_rsa.pub and root as default:
    ssh -N -D $lan -p $SSH_PORT $AWS_HOST &
    
    # echo "Autossh to $AWS_USER@$AWS_HOST using cert $AWS_CERT."
    # cat $PROFILE
    # export AUTOSSH_PATH='/opt/usr/bin/ssh'
    # export AUTOSSH_DEBUG=1
    # export AUTOSSH_LOGFILE='/tmp/autossh.log'
    # export AUTOSSH_LOGLEVEL=7
    # local ssh_option="ServerAliveInterval 20" 
    # autossh -f -M0 -N -o "$ssh_option" -D $lan -p 2222 -i $DIR/$AWS_CERT $AWS_USER@$AWS_HOST
    test $? -eq 0 && nag "Tunnel established."
    # sleep 3
	ps | grep ssh-daemon | grep -v -q grep
	if test $? -eq 0; then
		nag "Daemon is already running."
	else
		/bin/sh $DIR/ssh-daemon.sh -l -w -v &
		nag "Daemon started by `basename $0`."
		sleep 1
		nag "All done."
	fi	
}

reset()
{
	local tunnel_status=`status` 
	if test "$tunnel_status" == "ZOMBIE"; then
		nag "Tunnel is ZOMBIE. Resetting tunnel."
		force_kill
		tunnel
		# nag "Tunnel re-established."
	else
		nag "Status of tunnel is $tunnel_status. Request ignored."
	fi	
}

status()
{
    if test -n "`pidof ssh`"; then
		netcat -z -w 1 192.168.1.1 $SOCKS5_PORT
		if test $? -eq 0; then
			echo "LISTENING"
		else
			echo "ZOMBIE"
		fi	
    else
		source $PROFILE
		if test -n "$AWS_HOST"; then
			echo "CLOSED"
		else
			echo "DELETED"
		fi
    fi
}

showhost()
{
    test -z "$AWS_HOST" && . $PROFILE
    echo "$AWS_HOST" 
}

profile()
{
    cat $PROFILE
}

check()
{
    `dirname $0`/check.sh
}

usage()
{
    test -n "$*" && echo "Unknown action: $*"
    echo "usage: `basename $0` <Action> [<Arguments>]"
    exit 1
}

ACTION=$1
shift 1
test -z "$ACTION" && ACTION=tunnel
type $ACTION > /dev/null
test $? -eq 127 && usage $ACTION
$ACTION $*

