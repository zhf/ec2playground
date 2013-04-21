
regions=(us-west-1 ap-southeast-1 ap-northeast-1)
function each_region_check
{
    for r in "${regions[@]}"; do
        START=$(date +%s)
		printf $r
		ec2-describe-availability-zones --region $r >/dev/null
		case $? in
			0)
				END=$(date +%s)
				DIFF=$(( $END - $START ))
				;;
			*1)
				DIFF="(ERROR)"
				;;
		esac
		printf "\t %s seconds.\n" $DIFF
    done
}

each_region_check
