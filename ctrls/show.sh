DIR=`dirname $0`
. $DIR/../base/formats.sh
. $DIR/../base/choose.sh

function show_region
{
	local info="$DEV_VAR/aws/ins/$1"
	echo "$1:"
	awk -v region="$1" -v host=$AWS_HOST '/^INSTANCE/ \
		{ if ($6 == "running") printf("\033[01;36m"); else printf("\033[00;37m"); \
		if (host == $17) printf("\033[07m"); \
		printf("%12s %13s %16s %15s",$2,$6,$12,$17); \
		if ($6 == "running") { \
			printf("\033[00;33m"); \
			system("fping -C 1 -q "$17" 2>&1 | cut -d : -f 2 | tr -d \"\n\""); \
			printf(" ms\033[00;37m"); \
		} \
		printf("\n");
		} END {printf("\033[00m")}' $info
	echo "" # A blank line
}

source $ECS_DIR/base/regions.sh

eval `$ECS_DIR/apps/viarouter.sh '~/aws/fq.sh profile' | grep AWS_HOST`

Horiz
each_region_do show_region
Horiz
