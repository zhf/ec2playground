# Upload/sync the content of current directory to the cloud and share via a light web server

TARGET_LOCATION=/var/ecs_web
rsync -av -e 'ssh -l root' ./ $EC2_SEL_IP:$TARGET_LOCATION
$ECS_DIR/apps/exec.sh "cd $TARGET_LOCATION; python -m SimpleHTTPServer 8000"
test "`uname`" = "Darwin" && open http://$EC2_SEL_IP:8000/
