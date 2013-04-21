[ "`basename $0`" != "query.sh" ] && SOURCED="YES"

function usage
{
	echo "Usage: `basename $0` <Region> | all"
	exit 1
}

function prt
{
	[ "$SOURCED" != "YES" ] && printf "$*"
}

test -z "$1" && usage

DIR=`dirname $0`
test -z "$COLOR" && . $DIR/formats.sh

function query_region()
{
# 	prt " * Querying $BRIGHT$YELLOW $1 $RESET\n"
	local tmp="$LOC_TMP/aws/response.txt"
	ec2-describe-instances --region $1 --show-empty-fields > $tmp
	
	test ! -f $tmp && exit -1
		
	if grep 'timeout' $tmp; then
		rm $tmp
		$DIR/log.sh "Query: $1 [Timeout]"
		exit -1
	else
		$DIR/log.sh "Query: $1 [Okay]"
	fi
	
	mv $tmp "$DEV_VAR/aws/ins/$1"
	# say region refreshed
}

. $DIR/regions.sh

if [[ "$1" == "all" || "$1" == "A" ]]; then
	each_region_do query_region
else
	REGION=$1
	[ ${#REGION} == "1" ] && REGION=`grep ^$1 $DEV_ETC/aws/region-aliases | cut -f 2`
	query_region $REGION
fi

# prt "\n"
# [ "$SOURCED" != "YES" ] && $DIR/show.sh
