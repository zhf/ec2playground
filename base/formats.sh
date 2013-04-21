# 	Attributes
# Reset	0
# Bright	1
# Dim	2
# Underscor	4
# Blink	5
# Reverse	7
# Hidden	8
# 
# Foreground and Background Colours
# Black	30	40	
# Red	31	41
# Green	32	42
# Yellow	33	43
# Blue	34	44
# Magenta	35	45
# Cyan	36	46
# White	37	47

COLOR='\033[0;'
BRIGHT='\033[1;'
UNDERSCOR='\033[4;'
REVERSE='\033[7;'
RESET='\033[0m'
CLEAR=$RESET

BLACK='30m'
RED='31m'
GREEN='32m'
YELLOW='33m'
BLUE='34m'
MAGENTA='35m'
CYAN='36m'
WHITE='37m'

UNICODE_CHAR_V="✔ "
UNICODE_CHAR_X="✘ " 

BACKSPACE="\033[2D"

print_test()
{
    printf "%-25s\t" "$1"
}

begin_test()
{
    print_test "$1"
	printf "$BRIGHT$YELLOW$UNICODE_CHAR_V$CLEAR"
    # [ "`uname`" == "Darwin" ] && sleep 0.5
}

end_test()
{
	test $? -eq 0 && pass || fail 
}

backspace()
{
    printf "$BACKSPACE"
}

pass()
{
    backspace
    printf "$BRIGHT$GREEN$UNICODE_CHAR_V$CLEAR\n"
}

fail()
{
    backspace
    printf "$BRIGHT$RED$UNICODE_CHAR_X$CLEAR\n"
    test -n "$1" && exit $1
}

exam()
{
	local func=$1
	shift 1
	local prompt=$*
	
	begin_test $prompt
	$func
	local exit_status=$?
	if test $exit_status -eq 0; then
		pass
		return 0
	else
		fail $exit_status
	fi
}

Horiz()
{
	local width=$1
	test -z "$width" && width=`tput cols`
	printf "%${width}s\n"|tr ' ' '-'
}

