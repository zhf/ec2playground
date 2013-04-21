DIR=`dirname $0`
source $DIR/current.profile
source $DIR/tunnel.cfg

UNICODE_CHAR_V="✔ "
UNICODE_CHAR_X="✘ " 
GREEN="\033[1;32m"
YELLOW="\033[5;33m"
RED="\033[1;31m"
CLEAR="\033[0m"
BACKSPACE="\033[2D"

print_test()
{
    printf "%-25s\t" "$1"
}

begin_test()
{
    print_test "$1"
    printf "$YELLOW$UNICODE_CHAR_V$CLEAR"
    sleep 0
}

end_test()
{
    printf "$BACKSPACE"
}

pass()
{
    end_test
    printf "$GREEN$UNICODE_CHAR_V$CLEAR\n"
}

fail()
{
    end_test
    printf "$RED$UNICODE_CHAR_X$CLEAR\n"
    test -n "$1" && exit $1
}

begin_test "Profile exists?"
test -z "$AWS_HOST" && fail 1 
pass

begin_test "Response to ping?"
fping "$AWS_HOST" >/dev/null
test $? -eq 0 || fail 6
pass

begin_test "Port $SSH_PORT open?"
netcat -z -w 5 $AWS_HOST $SSH_PORT
test $? -eq 0 || fail 2
pass

begin_test "Daemon running?"
ps | grep ssh-daemon | grep -v -q grep
test $? -eq 0 || fail 5
pass

begin_test "Client running?"
test -z "`pidof ssh`" && fail 3 
pass

begin_test "Proxy listening?"
netcat -z -w 1 192.168.1.1 $SOCKS5_PORT
test $? -eq 0 || fail 7
pass

begin_test "Tunnel alive?"
curl --silent --connect-timeout 5 --max-time 10 --socks5 192.168.1.1:$SOCKS5_PORT --head example.com | grep -q 'HTTP/1'
test $? -ne 0 && fail 4
pass

exit 0
