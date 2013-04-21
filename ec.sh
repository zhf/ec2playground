#!/bin/bash

DIR=`dirname $0`
DEFAULT_COMMAND="show"

function usage
{
	printf "Usage:\n \t ec <command> [<arguments>]\n"
	printf "\nSub-commands for controls:\n"
	listof "ctrls"
	printf "\nSub-commands for apps:\n"
	listof "apps"
	echo
}

function error_not_found
{
	echo "`basename $0`: Sub-command not exists: $COMMAND"
	exit 2
}

function listof
{
	for i in `ls $DIR/$1/*.sh`
	do
		printf "\t - `basename -s .sh $i`\n"
	done
}

function make_alias
{
	grep 'alias ec=' ~/.bashrc || echo "alias ec='"$0"'" >> ~/.bashrc && echo "Alias created."
}

COMMAND="$1"
shift

case $COMMAND in
	*help)
		usage && exit 0
		;;
	make_alias)
		make_alias && exit 0
		;;
esac

test -z "$COMMAND" && COMMAND=$DEFAULT_COMMAND

COMMAND_SCRIPT="$DIR/ctrls/$COMMAND.sh"
if [ ! -f $COMMAND_SCRIPT ]; then
	COMMAND_SCRIPT="$DIR/apps/$COMMAND.sh"
	[ ! -f $COMMAND_SCRIPT ] && error_not_found
fi

ECS_DIR=`cd $DIR; pwd`
export ECS_DIR && $COMMAND_SCRIPT $*
