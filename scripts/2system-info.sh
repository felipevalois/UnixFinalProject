#!/bin/bash

echo '<ul>'
#1

echo '<li> Node name: '
hostname
echo '</li>'

#2

dist=$(cat /etc/os-release | grep "^NAME" | cut -d \" -f2)
echo '<li> Linux Distribution: '
echo $dist
echo '</li>'

#3
echo '<li> System Architecture'
uname --m
echo '</li>'

#4
echo '<li> Network Adapters'
ls /sys/class/net/
echo '</li>'

#5
temp=$(hostname -I)
classC='^(192.168)'
for t in $temp
do
	if [[ $t =~ $classC ]]
	then
		echo '<li> IP: '
		echo $t
		echo '</li>'
	fi
done

#6
echo '<li> Users Logged in: '
who | cut -d" " -f1 | uniq
echo '</li>'
#7
echo '<li>  HDD total space: '
df -h --output=size,source --total | grep total | sed 's/total//' | sed -e 's/^[[:space:]]*//'
echo '</li>'
#8
echo '<li> HDD used space: '
df -h --output=used,source --total | grep total | sed 's/total//' | sed -e  's/^[[:space:]]*//'
echo '</li>'
#9
echo '<li> Total memory (RAM): '
free -h | grep Mem | tr -s " " | cut -d" " -f2
echo '</li>'
#10
echo '<li> Used memory (RAM): '
free -h | grep Mem | tr -s " " | cut -d" " -f3
echo '</li>'
#11
echo '<li> Number of user accounts: '
ls /home | wc -l 
echo '</li>'

#12
users=0
for user in `ls /home`
do
	#echo -ne "$user\t"
	temp=$(last | grep $user | echo $?)
	#echo $temp
	if [[ $temp -eq 0 ]]
	then
		((users+=1))		
	fi
done
echo '<li> Number of users that have logged in: '
echo $users
echo '</li>'

#13
echo '<li> SHELL: '
echo $SHELL
echo '</li>'

#14
echo '<li> Home Directory'
echo $PWD
echo '</li>'

#15
echo '<li> Language: '
echo $LANG
echo '</li>'

echo '</ul>'


exit 0


