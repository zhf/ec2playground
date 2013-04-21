# echo "Using profile:"
# readlink ~/AWS/profile
# 
# echo "Downloading: $1"
# . ~/AWS/profile
# scp -i ~/AWS/$AWS_CERT $AWS_USER@$AWS_HOST:$1 .

function usage
{
	echo "Usage: `basename $0` <files>"
}

DIR="`dirname $0`"
. $DIR/choose.sh
LOCAL_DIR=~/Downloads
if test -z $SEL_EC2_IID; then
	echo "Choose a source to download file '$1' to $LOCAL_DIR:"
	if choose "-c running"; then
		scp -i $SEL_EC2_CERT -P 22 $SEL_EC2_LOGIN@$SEL_EC2_IP:"$1" $LOCAL_DIR
		. $DIR/log.sh
		$DIR/log.sh "Download: $1"
	fi
fi

