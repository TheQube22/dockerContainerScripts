#!/bin/bash

# stop all containers
docker stop $(docker ps -a -q)

# define container range
minContainer=100
maxContainer=310
useRNC=0

# initialize the macvlan network
docker network rm slnNetwork
docker network create -d macvlan --subnet=192.0.0.0/8 --ip-range=192.0.0.222/8 --gateway=192.168.255.1 -o parent=enp23s0f1 slnNetwork

# launch ifb module on the host. The containers will create their own virtual instance of this module.
ifconfig ifb0 down # is this necessary?
modprobe -r ifb # is this necessary?
modprobe ifb numifbs=1

# launch the containers
linkControllerFolderPath=/home/sln/Documents/docker/sln_docker/linkController
# NOTE: Not sure why nodeConfigure_v2.sh exists in both the sln_docker/ & the /rnc/opt/ directories
# Seeing as it's not an RNC-specific utility, seems to make more sense to use the sln_docker/ location,
# but they're the same file so it doesn't *really* make a difference either way (as long as we remember
# to make any updates to the one we're using, not the one we aren't using)
#nodeConfigureFilePath=/home/sln/Documents/docker/sln_docker/rnc/opt/nodeConfigure_v2.sh
nodeConfigureFilePath=/home/sln/Documents/docker/sln_docker/nodeConfigure_v2.sh
kcuAddressFilePath=/home/sln/Documents/docker/sln_docker/kcuAddresses.csv
for container in $(seq $minContainer $maxContainer)
do
    # launch the container
    docker container run -d --rm --name node$((container)) --privileged --network slnNetwork --ip 192.$((container/254)).$((container%254)).222 sln_image:v0.2
    # copy the python scripts to the container. Avoid mounting incase any logging or __pycache__ occurs in the shared directory.
    docker cp $linkControllerFolderPath node$((container)):/home
    docker cp $nodeConfigureFilePath node$((container)):/home
    docker cp $kcuAddressFilePath node$((container)):/home
done

echo Launched containers $minContainer:$maxContainer

# verify that at least one container can reach the physical network (other work station)
sleep 2
docker container exec node$((minContainer)) traceroute -n 192.168.255.2

for container in $(seq $minContainer $maxContainer)
do
    # block all OLSR packets
    docker container exec node$((container)) sudo iptables -A INPUT -s 192.0.0.0/8 -p udp -m udp --dport 698 -j DROP &
    # launch OLSR
    #docker container exec node$((container)) /opt/router/olsrd/olsrd -f /opt/router/olsrd/olsrd.conf
    # launch OLSR and RNC
    #docker container exec node$((container)) /opt/nodeConfigure.sh $((container)) docker eth0 > null.txt & # launch node config script
    # launch OLSR, new config script
    docker container exec node$((container)) bash /home/nodeConfigure_v2.sh $((container)) node-$((container)) eth0 $useRNC > null.txt &
done

echo Nodes are configuring. Please wait ten seconds.

# After the node config script finishes, all the nodes can see eachother (i.e. no iptables rules applied yet).
# Let all the nodes see eachother at first to max out RAM usage. Maxing out RAM usage reduces burden on CPU.
#sleep 600
for i in $(seq 10 -1 1)
do
    if [ $(( $i % 30)) == 0 ]
    then
        printf "${i}"
    else
        printf "-"
    fi
    sleep 1
done


for container in $(seq $minContainer $maxContainer)
do
    docker container exec node$((container)) python3 /home/linkController/linkController.py &
done

echo Launched python script!

exit 0

#TODO:
#- limit amount of CPU/MEM each container can use, so host never crashes.

# SSH into container:
# sudo docker container exec -it node67 /bin/bash


