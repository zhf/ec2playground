ec2-request-spot-instances \
--region us-east-1 \
--show-empty-fields \
ami-6ba27502 \
--price 0.009 \
--instance-type t1.micro \
--user-data-file $DEV_ETC/aws/init/startup.sh \
--group ssh \
--key zava_rsa.pub
