
function usage
{
	printf "Usage: %s: [-c Condition] [-h Hightlight] [-r Region] [-o Output-file-name] [-n]\n" $(basename $0) >&2
	exit 2
}

COND=".*"
REGION=
OUTPUT=$LOC_TMP/aws/list.tmp
NO_PRINT="NO"

while getopts "c:h:r:o:n" OPTION
do
	case $OPTION in
		c) 	COND="$OPTARG"
			;;
		h)	HIGHLIGHT="$OPTARG"
			;;
		r)	REGION="$OPTARG"
			;;
		o)	OUTPUT="$OPTARG"
			;;
		n)	NO_PRINT="YES"
			;;
		?)	usage
			;;
	esac
done
shift $(($OPTIND-1))

# echo "Using tmp file $OUTPUT" # DEBUG

if test -f $OUTPUT; then
	rm $OUTPUT
fi


export LIST_ID=1

function list_instances
{
	awk -v i=$LIST_ID -v cond="$COND" -v reversed="$HIGHLIGHT" -f $(dirname $0)/list.awk $DEV_VAR/aws/ins/$1 >> $OUTPUT
	LIST_ID=$?
}

if test -z "$REGION"; then
	. $(dirname $0)/regions.sh
	each_region_do list_instances
else
	list_instances $REGION
fi

test "$NO_PRINT" == "YES"  || cat $OUTPUT
