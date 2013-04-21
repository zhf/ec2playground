source $DEV_ETC/aws/tunnel.cfg
DIR=`dirname $0`
SECS="3"
. $DIR/formats.sh

function wait_for
{
	ACTIONS=($*)
	RETRY_TIMES=25
	for a in "${ACTIONS[@]}"
	do
		$a --init
		if (( $? != 0 )); then
			printf "\nAction $BRIGHT$RED$a$RESET failed to initialize.\n"
			exit -2
		fi

		local successed="NO"
		for i in $(eval echo {1..$RETRY_TIMES})
		do
			$a
			if (( $? == 0 )); then
				successed="YES"
				break
			else
				printf " ."
				sleep $SECS
			fi
		done

		if [ "$successed" == "YES" ]; then
			printf "\t$BRIGHT$GREEN[Done]\n$RESET"
		else
			printf "\t$BRIGHT$RED[Failed]\n$RESET"
			exit -1
		fi
	done
}

function assigning_ip
{
	case $1 in
		--init)
			printf "Waiting for assigning IP for instance"
			test -n "$REGION" -a -n "$IID"
			;;
		*)
			$DIR/query.sh $REGION
			grep --silent "^INSTANCE.*$IID.*ec2-.*amazonaws\.com" $DEV_VAR/aws/ins/$REGION
			;;
	esac			
}

function marked_as_running
{
	case $1 in
		--init)
			printf "Waiting for marking instance as running"
			test -n "$REGION" -a -n "$IID"
			;;
		*)
			$DIR/query.sh $REGION
			grep --silent "^INSTANCE.*$IID.*running" $DEV_VAR/aws/ins/$REGION
			;;
	esac			
}


function network_up
{
	case $1 in
		--init)
			printf "Waiting remote host to echo pings"
			type -t "auto_choose" | grep -q "function" || source $DIR/choose.sh
			auto_choose -c "$IID"
			test -n "$SEL_EC2_IP"
			;;
		*)
			fping -r 1 -q $SEL_EC2_IP
			;;
	esac
}

function sshd_up
{
	case $1 in
		--init)
			printf "Waiting for SSH service up"
			test -n "$SEL_EC2_IP" -a -n "$SSH_PORT"
			;;
		*)
			nc -z -w 5 $SEL_EC2_IP $SSH_PORT
			;;
	esac
}

function wait_for_services
{
	IID=$1
	REGION=$2
	wait_for assigning_ip marked_as_running network_up sshd_up
}






# wait_for ping_google_dns check_router_ssh_port
# function refresh_region
# {
# 	local region="$1"
# 	$DIR/query.sh $region
# }
# 
# function wait_for_dns
# {
# 	if test -z $1; then
# 		echo "$(basename $0): No instance id specified."
# 		return 1
# 	fi
# 	
# 	if test -z $2; then
# 		echo "$(basename $0): No region specified."
# 		return 1
# 	fi
# 	
# 	printf "Waiting for instance creation of $1 @ $2"
# 
# 	for i in {1..5}
# 	do
# 		refresh_region $2
# 
# 	 	grep --silent "^INSTANCE.*$1.*ec2-.*amazonaws\.com" $DEV_VAR/aws/ins/$2
# 		
# 		if (( $? == 0 )); then 
# 			printf "\t$BRIGHT$GREEN[Done]\n$RESET"
# 			return 0; 
# 		fi
# 		
# 		# printf "Waiting %s seconds ...\n" $SECS
# 		sleep $SECS
# 		printf " ."
# 		
# 		# DNS=$(getdns $1 $2)
# 		# 
# 		# if test -z "$DNS"
# 		# then
# 		# 	echo "Info not ready. Trying again ..."
# 		# else
# 		# 	echo "Public DNS name is:"
# 		# 	echo $DNS
# 		# 	return 0
# 		# fi
# 	done
# 
# 	echo "\n$(basename $0): DNS Timeout!\n"
# 	return -1
# }
# 
# function wait_for_ssh
# {
# 	wait_for_dns $1 $2
# 	if (( $? != 0 )); then
# 		return $?
# 	fi
# 
# 	. $DIR/choose.sh
# 	if ! auto_choose "-c $ID"; then
# 		printf "Internal error in $0!\n"
# 		exit -5
# 	fi
# 	
# 	printf "Waiting for IP up on $1 ($SEL_EC2_IP) @ $2"
# 	for i in {1..30}
# 	do
# 		fping -q $SEL_EC2_IP
# 		if (( $? == 0 )); then
# 			printf "\t$BRIGHT$GREEN[Done]\n$RESET"
# 			break
# 		fi
# 
# 		printf "$i-"
# 		sleep $SECS
# 	done
# 	printf "\n$(basename $0): ICMP Timeout!\n"
# 	return -3
# 
# 	printf "Waiting for SSH service on $1 ($SEL_EC2_IP:$SSH_PORT) @ $2"
# 	for i in {1..25}
# 	do
# 		nc -w 3 -z $SEL_EC2_IP $SSH_PORT
# 		if (( $? == 0 )); then
# 			printf "\t$BRIGHT$GREEN[Done]\n$RESET"
# 			return 0
# 		fi
# 		printf " $COLOR$MAGENTA$i$RESET"
# 		sleep $SECS
# 	done
# 	printf "\n$(basename $0): SSH Timeout!\n"
# 	return -2
# }
# 
# function ping_google_dns
# {
# 	if [ "$1" == "--init" ]; then
# 		printf "Checking Google DNS"
# 		return 0; 
# 	else
# 		fping -q 8.8.8.8
# 	fi
# }
# 
# function check_router_ssh_port
# {
# 	if [ "$1" == "--init" ]; then
# 		printf "Checking Router SSH"
# 		return 0; 
# 	else
# 		nc -w 5 -z 192.168.1.1 22
# 	fi
# }

# function getdns
# {
# 	ec2-describe-instances --region $2 --filter instance-id=$1 --filter instance-state-name=running | \
# 	awk 'FNR == 2 { if ($4 ~ /\.com$/) print $4 }' # Parsed value ending with *.com?
# }

