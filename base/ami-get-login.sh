
function get_login
{
	awk -v ami="$1" '$1 == ami { print $2; exit }' $DEV_ETC/aws/ami-logins
}