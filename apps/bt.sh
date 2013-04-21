# Install a BitTorrent software Transmission on the ec2 server and control it via web browser

case $1 in
	client)
		URL=http://$EC2_SEL_IP:9001
		if test "`uname`" = "Darwin"; then
			test -z "$EC2_SEl_IP" && auto_choose
			test -n "$EC2_SEl_IP" && open $URL
		else
			echo $URL
		;;
	setup)
		$ECS_DIR/apps/exec.sh "\
			apt-get install transmission-cli transmission-daemon; \
			/etc/init.d/transmission-daemon stop; \
			echo 'some settings' >> /etc/transmission-daemon/settings.json; \
			/etc/init.d/transmission-daemon start \
			"
		test $? -eq 0 && echo "Setup completed successfully."
		;;
esac
