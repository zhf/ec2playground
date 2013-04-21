# This script refreshes available zones of all regions

DIR=`dirname $0`
source $DIR/regions.sh

region_daz()
{
	printf "Querying $1 ...\t"
	ec2-describe-availability-zones --region $1 >$DEV_ETC/aws/zones/$1/az
	if (( $? == 0 )); then
		printf "Done!\n";
	else
		printf "Error!\n";
		exit -1
	fi
}

each_region_do region_daz
