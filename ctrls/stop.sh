DIR=$(dirname $0)
. $DIR/choose.sh
choose "-c running"
test -z "$SEL_EC2_IID" && exit -1

# ec tunnel notify stop_host
$DIR/router_fq.sh delete $SEL_EC2_IP

printf "Stopping instance %s @ %s ...\n" $SEL_EC2_IID $SEL_EC2_REGION
ec2-stop-instances --region $SEL_EC2_REGION $SEL_EC2_IID --force
. $DIR/log.sh
# echo "Waiting a few seconds ..."
# sleep 5
# echo "Refreshing local information ..."
# $DIR/query.sh $SEL_EC2_REGION
echo $DIR/query.sh $SEL_EC2_REGION | at now + 1 minute

# $DIR/show.sh

