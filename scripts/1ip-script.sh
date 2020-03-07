#!/bin/bash

#This script finds networks with a class C IP, and uses this IP to search for all instances in the IP range

#retrieving IP adresses from available interfaces
masterIps=$(hostname -I)
#masterIps='223.0.0.1 192.168.0.1'

#class C regex 
#classC='^(19[2-9]|2[01][0-9]|22[0-3])'

#private class C regex 
classC='^(192.168)'

valid=''

#iterating through IPS (default delimeter is whitespace)
for a in $masterIps
do
	#comparing each IP to regex
	if [[ $a =~ $classC ]]
	then
		valid+=$a
		valid+=" "
	fi
done

#assigning to an 'array' in case there are multiple valid IPS
arr=$(echo $valid | sed 's/ /\n/g')
#echo "$arr"

#removing host id
var=$(echo "$arr" | cut -d '.' -f1,2-3)
#echo $var


# iterating through every possible host in Master's node IP range 
# using xargs to ping each IP once 
# Flags 
# -n max-args -> -n1 -> 1 argument per command line 
# -P max-procs-> -P0 -> run as many processes as possible at a time
# Then grep is used to filter only successful requests
# Finally cut and sed to retrieve only the IP(s)

#for loop used in case there are multiple valid IPS
#echo "Pinging IPS on private network ..."
for a in $var
do
	#echo $a
	result=$(echo $a.{1..254}|xargs -n1 -P0 ping -c1|grep "bytes from"|cut -d' ' -f4,7|sed 's/://'|sed 's/time=0.//'|sort -n -k2|cut -d' ' -f1)
	#echo "Found: "
	echo $result
	#echo "\n"
	#array=($(echo $result | tr ' ' '\n'))

done

