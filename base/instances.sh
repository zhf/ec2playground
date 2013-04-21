OUTPUT_ENUM=$LOC_TMP/aws/enum.tmp

function enum_instance
{
	local args=$*
	`dirname $0`/list.sh -n -o $OUTPUT_ENUM $args
}

function each_instance
{
	local func=$1
	exec 3<&0
	exec 0<$OUTPUT_ENUM
	while read ins
	do
		# printf "Got: $ins"
		$func $ins
	done
	exec 0<&3
}

function instance_count
{
	awk 'END {print NR}' $OUTPUT_ENUM
}
