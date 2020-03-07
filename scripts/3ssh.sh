#!/bin/bash

ips=$(/home/user1/1ip-script.sh)
#echo $ips
#ips='192.168.1.30 192.168.1.10 192.168.1.20'

master='user1@'
node1='user2@'
node2='user3@'

array=($(echo $ips | tr ' ' '\n'))
master+="${array[0]}"

$(ssh user2@"${array[1]}" "echo test" >/dev/null 2>&1 )
ec=$?

if [[ $ec -eq 0 ]]
then
	node1+="${array[1]}"
	node2+="${array[2]}"
	#echo "1"
else
	node1+="${array[2]}"
	node2+="${array[1]}"
	#echo "2"
fi

ssh $master "bash -s" < /home/user1/2system-info.sh
ssh $node1 "bash -s" < /home/user1/2system-info.sh
ssh $node2 "bash -s" < /home/user1/2system-info.sh


