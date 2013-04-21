source `dirname $0`/common.sh

function usage
{
	printf "Usage:\n"
	printf "\t`basename $0` { delete <IP> | stop | status }\n"
	printf "\t`basename $0` [tunnel [<cert> <user> <host>]]\n"
	exit 1
}

# function ssh_command
# {
# 	local router_ssh_port=2222
# 	ssh -p $router_ssh_port root@192.168.1.1 "$*"
# }

function fq
{
	$DIR/viarouter.sh "sh ~/aws/fq.sh $*"
}

function tunnel
{
	. $DIR/choose.sh
	test -n "$SEL_EC2_IID" && auto_choose "-c $SEL_EC2_IID" || auto_choose "-c running"
	if [ -n "$SEL_EC2_IID" ]; then
		nag "Tunneling instance $SEL_EC2_IID @ $SEL_EC2_REGION ...\n" 
		# fq "tunnel $SEL_EC2_KEY.pem $SEL_EC2_LOGIN $SEL_EC2_IP $SEL_EC2_ZONE"
		fq "tunnel _ _ $SEL_EC2_IP $SEL_EC2_ZONE"
		test $? -eq 0 || return 2
		# read -p "Check tunnel? (y/n)"
		local lan="192.168.1.1:$SOCKS5_PORT"
		# [ $REPLY == "y" ] && \
		$DIR/router_ping.sh "$SEL_EC2_IP" && $DIR/check-tunnel.sh 
		# Update IM status
		# adium-change-status $SEL_EC2_IP
	fi
}

if test "`basename $0`" == "router_fq.sh"; then
	ACTION=$1
	shift 1

	test -z "$ACTION" && ACTION="tunnel"

	if test "$ACTION" == "tunnel" && test -z "$*"; then
		tunnel
	else
		fq $ACTION $*
	fi
else
	# This script is being sourced
	tunnel
fi
