source $DEV_ETC/aws/tunnel.cfg
HIGH_PORT=$SSH_PORT
CONNECT_TIMEOUT=5

STD_PORT=22
STD_CONNECT_TIMEOUT=30

echo "Running EC2 instances:"
. $(dirname $0)/choose.sh

SSH_ARGS="$*"

function ssh_command
{
	printf $COLOR$CYAN
	ssh $SSH_ARGS -p $1 -o "ConnectTimeout $2" -i $SEL_EC2_CERT $SEL_EC2_LOGIN@$SEL_EC2_IP
}

if choose "-c running"; then
	# echo -e "\033[00;36m" # Change color to dark cyan
	echo "Trying connecting via port $HIGH_PORT ..."
	nc -z -w 5 $SEL_EC2_IP $HIGH_PORT > /dev/null
	if [ $? -eq 0 ]; then
		ssh_command $HIGH_PORT $CONNECT_TIMEOUT
	else
		printf "Port $HIGH_PORT is not available. Connect thru standard port."
		ssh_command $STD_PORT $STD_CONNECT_TIMEOUT
	fi

#	if (( $? == 255 )); then
#		# echo -e "\033[00;31m" # Change color to dark red
#		# echo "Timeout, trying again with standard port ..."
#		# echo -e "\033[00;36m" # Change color to dark cyan
#		printf "$COLOR$RED Timeout, trying again with standard port ..."
#		ssh_command $STD_PORT $STD_CONNECT_TIMEOUT
#	fi
fi
