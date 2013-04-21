# Use system nc
PATH=/usr/bin/:$PATH

DIR=`dirname $0`
. $DIR/formats.sh
COLS=35
source $DEV_ETC/aws/tunnel.cfg

function usage
{
	printf "Usage: %s <socks5-proxy>[:port]\n" "`basename $0`"
	exit 1
}

# test -z "$1" && usage
# Now find the router's address
function get_router
{
	route get default | grep gateway | awk '{print($2)}'
}

function www_grab_head
{
	local url=$1
	test -z "$url" && return -1
	curl --silent --connect-timeout 5 --show-error --socks5 $GATEWAY --head $url  | grep 'HTTP/1' >/dev/null
	return $?
}

GATEWAY=`expr "$1" '|' $(get_router)`

url_test="www.youtube.com/robots.txt"
url_test_list="www.amazon.com www.minghui.com"

printf "\nRunning router tests ...\n"
Horiz $COLS
$DIR/router_fq.sh check

test $? -eq 0 || exit 5

printf "\nRunning local tests ...\n"
Horiz $COLS

function t_port
{
	nc -z -w 5 $GATEWAY $SOCKS5_PORT >/dev/null
}

exam t_port "Router socks5 port open?"

function t_proxy
{
	nc -z -w 5 -x $GATEWAY -X 5 8.8.8.8 53 >/dev/null
}

exam t_proxy "Netcat Google DNS via proxy?"

for i in $url_test_list
do
	begin_test "cURL $i"
	www_grab_head $i
	test $? -eq 0 || fail 30
	pass
done

Horiz $COLS
printf "All tests have passed!\n"
exit 0

#for i in {1..5}
#do
#	printf "Trying %d times to connect socks ...\t" $i
#	printf "$BRIGHT$CYAN"
#	curl --silent --connect-timeout 5 --show-error --socks5 $GATEWAY --head $url_test  | grep '200 OK'
#	if (($? == 0)); then 
#		printf "Checking http connect time ...\n"
#		for url in $url_test_list
#		do
#			printf "$BRIGHT$RED$url:\n$COLOR$GREEN"
#			curl --socks5 $GATEWAY --head $url | grep 'HTTP/1'
#		done
#		printf "$RESET"
#		exit 0
#	fi
#	printf "$RESET"
#	sleep 3
#done
#echo "$(basename $0): Timeout!"
