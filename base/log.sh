function usage
{
	printf "Usage: Source `basename $0` into another script or use:\n"
	printf "`basename $0` <message>\n"
	printf "`basename $0` --ping <host>\n"
	exit 1
}

LOG_CMDS="$DEV_VAR/aws/log/aws_commands.log"
LOG_PING="$DEV_VAR/aws/log/ping.log"

function get_time
{
	printf "`date '+%Y-%m-%d% %H:%M:%S'`"
}

function log
{
	local id=`expr "$ID" '|' "$SEL_EC2_IID"`
	local zone=`expr "$AZ" '|' "$SEL_EC2_ZONE"`
	printf "%s\t%s\t%s\t%s\n" \
		   	"$(get_time)" \
			"`basename $0`" \
			"$id" \
			"$zone" \
			>> $LOG_CMDS
}

function log_pingtime
{
	local addr="$1"
	local zone=`expr $AZ '|' $SEL_EC2_ZONE`
	printf "\n$(get_time)\t$zone" >> $LOG_PING
	ping -c 3 $addr >> $LOG_PING
}

if [[ "`basename $0`" != "log.sh" ]]; then
	# This file has been sourced into another script
	log
else
	test -z "$1" && usage
	if [ "$1" == "--ping" ]; then
		log_pingtime $2
	else
		printf "%s\t%s\n" "$(get_time)" "$*" >> $LOG_CMDS
	fi
fi