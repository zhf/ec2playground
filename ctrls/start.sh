DIR=$(dirname $0)
. $DIR/choose.sh
if choose "-c stop"; then
	printf "Starting instance %s @ %s...\n" $SEL_EC2_IID $SEL_EC2_REGION
	ec2-start-instances --region $SEL_EC2_REGION $SEL_EC2_IID
	
	. $DIR/wait.sh
	if wait_for_services  $SEL_EC2_IID $SEL_EC2_REGION; then
		. $DIR/log.sh
		# ec tunnel notify start_host
		read -p "Tunnel router? (y/n)"
		if [ $REPLY == 'y' ]; then
			. $DIR/router_fq.sh
		fi
		# $DIR/query.sh $SEL_EC2_REGION
		$DIR/show.sh
	fi
fi
