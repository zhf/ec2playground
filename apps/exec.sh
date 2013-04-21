function usage
{
	printf"Usage: `basename $0` <Commands>\n"
	exit 1
}

(( $# == 0 )) && usage

DIR=`dirname $0`

echo "Run '$*' on an instance:"
. $DIR/choose.sh

if auto_choose "-c running"; then
	ssh -i $SEL_EC2_CERT $SEL_EC2_LOGIN@$SEL_EC2_IP $*
	. $DIR/log.sh
	$DIR/log.sh "Execute: $*"
fi
