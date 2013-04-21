DIR=`basedir $0`
FILE_LOGINS="$DEV_ETC/aws/ami-logins"
FILE_REGIONS="$DIR/regions.sh"

function usage
{
	printf "Usage: %s: [-i Instance-ID] [-r Region] <Commands>\n" $(basename $0) >&2
	exit 2
}

IID=
REGION=

while getopts 'i:r:' OPTION
do
	case $OPTION in
		i)	IID="$OPTARG"
			;;
		r)	REGION="$OPTARG"
			;;
		?)	usage
			;;
	esac
done
shift $(($OPTIND - 1))

if (( $# == 0 )); then usage; fi
CMD="$*"

function exec_cmd
{
	awk -v file_logins="$FILE_LOGINS" -v iid="$IID" -v remote_cmd="$CMD" -f $DIR/exec.awk $DEV_VAR/aws/ins/$1
}

# If IID is omited, all running instances are called
if test -z $REGION; then
	. $FILE_REGIONS
	each_region_do exec_cmd
else
	exec_cmd $REGION
fi