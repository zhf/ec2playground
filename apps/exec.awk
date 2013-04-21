# External variable
# file_logins: list if ami-login key-pais
# iid: Instance id (optional)
# remote_cmd: Remote command to execute

function zone_to_region(s)
{
	return substr(s, 1, length(s)-1);
}

BEGIN {
	while ((getline < file_logins) > 0)
	{
		login_list[$1] = $2
	}
}

/^INSTANCE/ {
	if ($6 == "running" && (iid == "" || iid == $2))
	{
		printf("%12s %12s %16s %s\n",$2,$3,$12,$4);
		login=login_list[$3];
		region=zone_to_region($12);
		cert=$7;
		dns=$4;
		# aws_pool=ENVIRON["AWS_POOL"];
		aws_etc=ENVIRON["DEV_ETC"]/aws;
		# remote_cmd="uptime"
		ssh_cmd="ssh -i "aws_etc"/zones/"region"/certs/"cert".pem "login"@"dns" "remote_cmd;
		# print(ssh_cmd);
		system(ssh_cmd);
	}
}
