DIR=`dirname $0`
source $DIR/ec2.conf
source $DIR/formats.sh
source $EC2_ETC/tunnel.cfg

function usage
{
	printf "Usage: %s <region_short_name> [<city_short_name>]\n" `basename $0`
	exit 1
}

function launch
{
	local options="$AMI_ID --region $REGION \
						--group $GROUP \
						--key $KEY  \
						-t t1.micro \
						--user-data-file $DEV_ETC/aws/init/startup.sh \
						--instance-initiated-shutdown-behavior terminate \
						--availability-zone $AZ"
	ID=`ec2-run-instances $options | grep 'INSTANCE' | cut -f 2`
	[[ "$ID" =~ i-* ]]
}

[ -n "$1" ] && [[ -d $DEV_ETC/aws/zones/$1 ]] || usage

REGION=`grep ^$1 $DEV_ETC/aws/region-aliases | cut -f 2`

echo "List of current instances in $REGION:"
$DIR/list.sh -r $REGION
# . "$DEV_ETC/aws/zones/$REGION/profiles/_"

test -n "$2" && AZ=`cut -f 2 $DEV_ETC/aws/zones/$1/az | grep $2$`

if test -z "$AZ"; then
	AZ_LIST=`cut -f 2 $DEV_ETC/aws/zones/$1/az`

	PS3="Where to run? "
	printf "$BRIGHT$BLUE\nAvailability zones:\n$RESET"
	select AZ in $AZ_LIST
	do
		test -n "$AZ" || exit 1
		break
	done
fi

PROFILE_LIST="$DEV_ETC/aws/zones/$1/profiles/*.profile" 
PS3="Which profile to use? "
printf "$BRIGHT$BLUE\nProfiles:\n$RESET"
select PROFILE in $PROFILE_LIST
do
	test -f $PROFILE &&	break
done

source $PROFILE
test -z $KEY && KEY=$DEFAULT_KEY
test -z $LOGIN && LOGIN=$DEFAULT_LOGIN

Horiz
echo "Launching a new instance in $AZ using `basename $PROFILE` ..."
launch

if (( $? != 0)); then
	echo "Error launching instance!"
	exit -1
else
	echo "Instance_id is $ID"
	if [ "`uname`" == "Darwin" ]; then
		say "got instance i-d"
	fi
	# schedule a query
	echo "ec query $1" | at now + 1 hour
fi

. $DIR/wait.sh
if wait_for_services $ID $REGION; then
	. $DIR/log.sh # Log this launch
	$DIR/show.sh
fi

. $DIR/choose.sh
if auto_choose "-c $ID"; then
	nc -w 1 -z $ROUTER_IP $SOCKS5_PORT
	(( $? == 0 )) && read -p "Override existing tunnel on router? (Y/n)" && [ "$REPLY" == "n" ] && exit 0
	. $DIR/router_fq.sh 
	# $DIR/show.sh
fi

if [ "`uname`" == "Darwin" ]; then
	say "instance launched"
	osascript -e "tell application \"Firefox\" to launch"
fi	
