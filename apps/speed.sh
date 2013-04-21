source $DEV_ETC/aws/tunnel.cfg

# Debian Family only
# TEST_FILE=/var/cache/apt/pkgcache.bin
TEST_FILE=speedtest.bin
LOCAL_DIR=/tmp

DIR="`dirname $0`"
. $DIR/formats.sh

if test -z $SEL_EC2_IID; then
	. $DIR/choose.sh
	echo "Choose an instance to test speed:"
	choose "-c running"
fi

test -z "SEL_EC2_IID" && exit -1

printf "$COLOR$CYAN"
scp -v -i $SEL_EC2_CERT -P $SSH_PORT -o "Compression no" $SEL_EC2_LOGIN@$SEL_EC2_IP:"$TEST_FILE" $LOCAL_DIR
printf "$COLOR$RESET"
. $DIR/log.sh

