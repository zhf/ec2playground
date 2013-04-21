# External variables
# i: list index number. Caller should increase it among calls
# cond: Pattern of condition to match of each line in additon to /^INSTANCE/
# bold:	Pattern of condition to match line with bold font
# reversed: Pattern of condition to match line with reversed font

# 1 •	Output type identifier ("INSTANCE")
# 2 •	Instance ID for each running instance 
# 3 •	AMI ID of the image on which the instance is based 
# 4 •	Public DNS name associated with the instance. This is only present for instances in the running state. 
# 5 •	Private DNS name associated with the instance. This is only present for instances in the running state. 
# 6 •	Instance state 
# 7 •	Key name. If a key was associated with the instance at launch, its name will appear. 
# 8 •	AMI launch index 
# 9 •	Product codes attached to the instance 
#10 •	Instance type 
#11 •	Instance launch time 
#12 •	Availability Zone 
#12 '	aki-??????	
#13 •	Kernel ID 
#14 •	RAM disk ID 
#15 •	Monitoring state 
#16 •	Public IP address 
#17 •	Private IP address

function zone_to_region(s)
{
	return substr(s, 1, length(s)-1);
}

function zone_to_city(s)
{
	return substr(s, length(s), length(s));
}

/^INSTANCE/ {
	if ($0 ~ cond)
	{
		region=zone_to_region($12);
		city=zone_to_city($12);
		# if ($0 ~ bold) printf("\033[1m");
		# if (reversed != '' && $0 ~ reversed) printf("\033[7m");
		printf("%2d %10s %10s %10s %14s %1s %15s %12s\n", i, $2, $3, $6, region, city, $17, $7);
		# printf "\033[0m"
		i++;
	}
}

END {
	exit i;
}
