source $ECS_DIR/base/common.sh
source $DEV_ETC/aws/tunnel.cfg

ROUTER_SSH_PORT=2222

function usage
{
	printf "Usage:\n"
	printf "\t`basename $0` { <command> }\n"
	exit 1
}

CMD=$*

test -z "$CMD" && usage

ssh -p $ROUTER_SSH_PORT root@$ROUTER_IP "$CMD"
