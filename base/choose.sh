source $ECS_DIR/ec2.conf
source $ECS_DIR/base/instances.sh
source $ECS_DIR/base/formats.sh

selections="$EC2_TMP/selections.tmp"

function pick
{
	awk -v l=$1 -v f=$2 -f $ECS_DIR/base/choose.awk $selections
}

function parse
{
	n=$1
	SEL_EC2_IID=$(pick $n 2)
	# echo $SEL_EC2_IID
	if test -z "$SEL_EC2_IID"; then
		echo "$(basename $0): Unable to extract instance information." 
		return 1; 
	fi

	SEL_EC2_AMI=$(pick $n 3)
	SEL_EC2_STATE=$(pick $n 4)
	SEL_EC2_REGION=$(pick $n 5)
	SEL_EC2_CITY=$(pick $n 6)
	SEL_EC2_ZONE="$SEL_EC2_REGION$SEL_EC2_CITY"
	SEL_EC2_IP=$(pick $n 7)
	SEL_EC2_KEY=$(pick $n 8)
	# FIXIT
	if [ "$SEL_EC2_KEY" == "$DEFAULT_KEY" ]; then
		SEL_EC2_CERT=$DEFAULT_KEY
	else
		SEL_EC2_CERT="$DEV_ETC/aws/zones/$SEL_EC2_REGION/certs/$SEL_EC2_KEY.pem"
	fi
	
	source $ECS_DIR/base/ami-get-login.sh
	#SEL_EC2_LOGIN=$(get_login $SEL_EC2_AMI)
	#test -z "$SEL_EC2_LOGIN" && SEL_EC2_LOGIN=$DEFAULT_LOGIN
	SEL_EC2_LOGIN=root
}

function choose
{
	printf $BRIGHT$CYAN
	$ECS_DIR/base/list.sh -o $selections $*
	printf $UNDERSCOR$YELLOW 
	read -p "Which one? "
	printf $RESET
	
	parse $REPLY
}

function auto_choose
{
	enum_instance $*
	selections=$OUTPUT_ENUM
	if test $(instance_count) -eq 1 ; then
#		printf $BRIGHT$CYAN
#		each_instance echo
#		printf $RESET
		parse 1
	elif (( $(instance_count) > 1 )); then
		choose $*
	else
		return 1
	fi
}

# function choose_all
# {
# 	enum_instance $*
# 	if (( $(instance_count) >= 1 )); then
# 		each_instance parse
# 	else
# 		return 1
# 	fi
# }
