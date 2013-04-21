DIR=`dirname $0`
source $DIR/choose.sh
auto_choose "-c running"

test -n $SEL_EC2_IP || exit -1
parent_host=$SEL_EC2_IP
squid_conf=/opt/local/etc/squid/squid.conf

sudo sed -i -e '/^cache_peer/d' $squid_conf
# echo "cache_peer $parent_host parent 9443 0 ssl sslcert=/opt/local/etc/squid/server.crt sslkey=/opt/local/etc/squid/server.key sslflags=DONT_VERIFY_PEER" | sudo tee -a $squid_conf

# Launch or reconfigure squid
ps -e | grep -e squid | grep --silent -v grep
if (( $? == 0 )); then
	sudo squid -k reconfigure
else
	sudo squid
fi
