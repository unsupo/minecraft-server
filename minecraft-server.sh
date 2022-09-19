#!/bin/sh
# Server Startup Script
dir=minecraft
mkdir $dir 2>/dev/null
cd $dir
script=minecraft.sh
pid=minecraft.pid
major_version=1.19

latest () {
	api_output=$(curl https://api.papermc.io/v2/projects/paper/version_group/$major_version/builds) #| python -c "import sys, json; print(json.load(sys.stdin)['builds'][-1]['downloads']['application']['name'])")
	latest_jar=$(echo $api_output | python -c "import sys, json; print(json.load(sys.stdin)['builds'][-1]['downloads']['application']['name'])")
	latest_build=$(echo $api_output | python -c "import sys, json; print(json.load(sys.stdin)['builds'][-1]['build'])")
        latest_version=$(echo $api_output | python -c "import sys, json; print(json.load(sys.stdin)['builds'][-1]['downloads']['version'])")
	curl https://api.papermc.io/v2/projects/paper/versions/$latest_version/builds/$latest_build/downloads/$latest_jar -o paper.jar
}
[ -e paper.jar ] && echo "paper.jar already exists skipping download...." || curl https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/138/downloads/paper-1.19.2-138.jar -o paper.jar

# Set the EULA to already be TRUE
[ -e eula.txt ] && echo "eula.txt already exists skipping download..." || curl https://raw.githubusercontent.com/unsupo/minecraft-server/main/eula.txt -o eula.txt

# Set the EULA to already be TRUE
[ -e server.properties ] && echo "server.properties already exists skipping download..." || curl https://raw.githubusercontent.com/unsupo/minecraft-server/main/server.properties -o server.properties

# Edit the below values to change JVM Arguments or Allocated RAM for the server
ALLOCATED_RAM="1G"
JVM_ARGUMENTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"
# Comment this line if you are are using over 13 GB of ram
JVM_ARGUMENTS_RAM="-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15"
# Uncomment this line if you are are using over 13 GB of ram
#JVM_ARGUMENTS_RAM="-XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:InitiatingHeapOccupancyPercent=20"
start () {
	# Starting the server
        echo "Starting the Server."
        echo "java -jar -Xms${ALLOCATED_RAM} -Xmx${ALLOCATED_RAM} ${JVM_ARGUMENTS} ${JVM_ARGUMENTS_RAM} paper.jar nogui" > $script && chmod +x $script
        nohup ./$script & echo $! > $pid
}
stop () {
	kill -9 $(cat $pid)
}

if [ -z "$1" ] || [ "start" = "$1" ]; then
	start
elif [ "stop" = "$1" ]; then
	stop
elif [ "restart" = "$1" ]; then
	stop
	start
elif [ "update" = "$1" ]; then
	curl https://api.papermc.io/v2/projects/paper/version_group/1.19/builds | python -c "import sys, json; print(json.load(sys.stdin)['builds'][-1]['downloads']['application']['name'])"
fi

