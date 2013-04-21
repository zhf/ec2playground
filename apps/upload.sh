
DIR="`dirname $0`"
. $DIR/choose.sh

if test -f $1; then
	if test -z $SEL_EC2_IID; then
		echo "Choose a target to upload file '$1':"
		if choose "-c running"; then
			scp -i $SEL_EC2_CERT -P 22 "$1" $SEL_EC2_LOGIN@$SEL_EC2_IP:~
			. $DIR/log.sh
			$DIR/log.sh "Upload: $1"
		fi
	fi
else
	echo "$(basename $0): File to upload does not exist."
	exit
fi

