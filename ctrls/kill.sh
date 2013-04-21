DIR=$(dirname $0)
. $DIR/choose.sh
. $DIR/formats.sh
if choose "-c running"; then
	# ROUTER_IID=$(cat $DEV_VAR/aws/iid-router)
	# if [[ $ROUTER_IID == $SEL_EC2_IID ]]; then
	# 	printf "$COLOR$RED Stopping router's tunnel ... \n $RESET"
	# 	$DIR/router_fq.sh -q
	# fi
	$DIR/router_fq.sh delete $SEL_EC2_IP
		
	printf "Terminating instance %s @ %s ...\n" $SEL_EC2_IID $SEL_EC2_REGION
	printf $COLOR$GREEN
	ec2-terminate-instances --region $SEL_EC2_REGION $SEL_EC2_IID
	printf $RESET
	. $DIR/log.sh

	# echo "Waiting a few seconds ..."
	# sleep 5
	# echo "Refreshing local information ..."
	echo $DIR/query.sh $SEL_EC2_REGION | at now + 1 minute
	echo "Local information will be refreshing soon."
	# $DIR/show.sh
fi
