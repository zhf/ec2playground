. `dirname $0`/choose.sh
if auto_choose "-c running"; then
	rdig $* $SEL_EC2_IP
fi

