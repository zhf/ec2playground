# regions=(us-east-1 us-west-1 us-west-2 ap-southeast-1 ap-northeast-1)
regions=(`cut -f 2 $DEV_ETC/aws/region-aliases`)
function each_region_do
{
	for r in "${regions[@]}"; do
		$1 $r
	done
}
