# Search a 

usage()
{
}

URL=$1
FILETYPE=$2
test -z "$FILETYPE" && usage && exit 1

wget [OPTIONS] $URL