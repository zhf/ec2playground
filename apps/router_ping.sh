DIR=`dirname $0`
IP="$*"
. $DIR/choose.sh
test -z "$IP" && auto_choose '-c running' && IP=$SEL_EC2_IP 

test -n "$IP" && $DIR/viarouter.sh ping -c 3 $IP

