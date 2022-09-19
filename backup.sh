# stop server
/home/jarndt/minecraft/paper.sh stop
# backup
git add .
git commit -m  "$(date +%s)"
git push
# start server
/home/jarndt/minecraft/paper.sh start
