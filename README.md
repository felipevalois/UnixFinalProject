# Felipe Costa - CS3530 Final Project

## 0. Link to instance
[AWS EC2](http://ec2-18-212-183-199.compute-1.amazonaws.com:8080/)

## 1. Manual Process

### 1.1 VMs Deployment
Three Vms were deployed on VMWare Fusion: Master(Debian), Node1(Ubuntu) and Node2(CentOS) using the following images.

[1] [Debian 10.2.0](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.2.0-amd64-netinst.iso)  
![](/Users/felipecosta/Desktop/Default-Screenshots/1Debian.png)
**Figure 1** - Master node (Debian)
<br/>

[2] [Ubuntu 18.04.3](http://releases.ubuntu.com/18.04/ubuntu-18.04.3-desktop-amd64.iso)
![](/Users/felipecosta/Desktop/Default-Screenshots/2Ubuntu.png)
**Figure 2** - Node1 (Ubuntu)
<br/>

[3] [CentOS 7.7.1908](http://mirror.mobap.edu/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso)
![](/Users/felipecosta/Desktop/Default-Screenshots/3CentOS.png)
**Figure 3** - Node2 (CentOS)


### 1.2 Dependencies for Project
#### Installing Dependencies
**I) VMWare tools**  
```bash
su -
apt-get update  
apt-get upgrade  
apt-get install build-essential module-assistant  
```
*(on VMWare menu)*  Virtual Machine -> install VMWare Tools  
Open mounted disk containing compressed file
extract compressed file to user's home dir

```bash
cd vmware-tools-distrib
sudo ./vmware-install.pl
reboot
```

**II) Net-tools**
```bash
sudo apt-get install net-tools
```
OR  
```bash
yum install net-tools
```

**III) SSH service**
```bash
sudo apt-get install openssh-server -y
```

**IV) SSH Key**  
Generated key-pair to ssh into Nodes without password authentication, this is not only more secure but also works better with scripts

*On master node*  
```bash
ssh-keygen
ssh-copy-id user2@192.168.1.20
ssh-copy-id user3@192.168.1.30
```

Edited the file /etc/ssh/sshd_config (for both nodes)  
Changed line ‘#PasswordAuthentication yes’ to ‘PasswordAuthentication no’
```bash
sudo service sshd restart
```

### 1.3 Users
*DEBIAN*
```bash
su -
adduser user1
usermod -aG sudo user1
reboot
```
![](/Users/felipecosta/Desktop/Default-Screenshots/user1.png)
**Figure 4** - User1

*UBUNTU*
```bash
sudo adduser user2
usermod -aG sudo user2
```
![](/Users/felipecosta/Desktop/Default-Screenshots/user2.png)
**Figure 5** - User2  


*CENTOS*
```bash
adduser user3
usermod -aG wheel user3
```
![](/Users/felipecosta/Desktop/Default-Screenshots/user3.png)
**Figure 6** - User3

### 1.4 Network Configuration
*Master (Debian)*  
Virtual Machine -> Settings -> Add Device -> Network Adapter -> Private to my Mac  
```bash
sudo ifconfig ens37 192.168.1.10 netmask 255.255.255.0
dhclient -r
dhclient
cat /etc/network/interfaces >>
"
auto ens37
iface ens37 inet static
  address 192.168.1.10
  netmask 255.255.255.0
"
sudo reboot
```

*Node1 (Ubuntu)*  
Change from share with mac to private to my mac
```bash
sudo ifconfig ens33 192.168.1.20 netmask 255.255.255.0
dhclient -r
dhclient
cat >> /etc/network/interfaces
"
auto ens33
iface ens33 inet static
  address 192.168.1.20
  netmask 255.255.255.0
"
sudo reboot
```

*Node2 (CentOS)*
Change from share with mac to private to my mac
```bash
ip address add 192.168.1.30 dev ens33
sudo vi /etc/sysconfig/network-scripts/ifcfg-ens33
```
Modify/add lines highlighted below:
![](/Users/felipecosta/Desktop/Default-Screenshots/6CentOS-network-scripts.png) **Figure 7** - /etc/sysconfig/network-scripts/ifcfg-ens33


### 1.5 AWS Instance
Go to AWS Console -> EC2 Dashboard -> Launch Instance  
1. Choose AMI -> Ubuntu 18.04
2. Instance Type -> t2.micro (free tier)
3. Configure Security Group -> Add following rules:
   - SSH (Port 22)
   - HTTP (Port 80)
   - HTTPS (Port 443)
   - Custom TCP (Port 8080)
4. Leave the remaining configurations as the default, and launch it

![](/Users/felipecosta/Desktop/Default-Screenshots/AWS1.png)
**Figure 8** - AWS instance

![](/Users/felipecosta/Desktop/Default-Screenshots/AWS2.png)
**Figure 9** - EC2 Dashboard

![](/Users/felipecosta/Desktop/Default-Screenshots/AWS3.png)
**Figure 10** - SSH into instance

After that I installed Docker
```bash
sudo apt-get update
sudo apt-get upgrade
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## 2. Local Process
I decided to use a single script for each step.

### 2.1 Identifying IP(s)
Script 1 : 1ip-script.sh
```bash
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
	result=$(echo $a.{1..254}|xargs -n1 -P0 ping -c1|grep "bytes from"|cut -d' ' -f4,7|sed 's/://'|sed 's/time=0.//'|sort -n -k2|cut -d' ' -f1)
	#echo "Found: "
	echo $result
done
```

### 2.2 Gathering Info
Script: 2system-info.sh  
In the original script I added html tags, but removed here for ease of readability.

```bash
#!/bin/bash

#1
hostname

#2
dist=$(cat /etc/os-release | grep "^NAME" | cut -d \" -f2)
echo $dist

#3
uname --m

#4
ls /sys/class/net/

#5
temp=$(hostname -I)
classC='^(192.168)'
for t in $temp
do
	if [[ $t =~ $classC ]]
	then

		echo $t

	fi
done

#6
who | cut -d" " -f1 | uniq

#7
df -h --output=size,source --total | grep total | sed 's/total//' | sed -e 's/^[[:space:]]*//'

#8
df -h --output=used,source --total | grep total | sed 's/total//' | sed -e  's/^[[:space:]]*//'

#9
free -h | grep Mem | tr -s " " | cut -d" " -f2

#10
free -h | grep Mem | tr -s " " | cut -d" " -f3

#11
ls /home | wc -l

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
echo $users

#13
echo $SHELL

#14
echo $PWD

#15
echo $LANG

exit 0
```

## 3. Remote Process
Here is where it all ties together. I used two separate scripts to achieve the goal.

The first one: 3ssh.sh finds the IPS by calling the 1ip-script.sh, then it sshs into each node and calls the 2system-info.sh to collect the information.
```bash
#!/bin/bash

ips=$(/home/user1/1ip-script.sh)

master='user1@'
node1='user2@'
node2='user3@'

#assigning IPS to an 'array'
array=($(echo $ips | tr ' ' '\n'))

#master ip's should be the first one since it was sorted by response time on 1ip-script.sh
master+="${array[0]}"


$(ssh user2@"${array[1]}" "echo test" >/dev/null 2>&1 )
ec=$?

#if user2 successfully sshs using the second IP, match user2 with its IP
# only one IP left assign it to user3
if [[ $ec -eq 0 ]]
then
	node1+="${array[1]}"
	node2+="${array[2]}"
else
   #else, if ssh was unsucesfull assign the other IP
	node1+="${array[2]}"
	node2+="${array[1]}"
	#echo "2"
fi

#ssh into each node and call the script to gather all the information
ssh $master "bash -s" < /home/user1/2system-info.sh
ssh $node1 "bash -s" < /home/user1/2system-info.sh
ssh $node2 "bash -s" < /home/user1/2system-info.sh
```  

The last script (ec2.sh), is the only one that is executed manually in the command line.  

It calls the script 3ssh.sh and saves the output to an html file. Next, we ssh into the ec2 instance and create a new container.  

Lastly the html file is sent to the ec2 instance using scp.

```bash
#!/bin/bash

./3ssh.sh | tee index.html

#start a web server in a container using port 8080
ssh -t -i "CS3530.pem" ubuntu@ec2-18-212-183-199.compute-1.amazonaws.com \
	"sudo docker run -dit --name final-project -p 8080:80 -v '/home/ubuntu':/usr/local/apache2/htdocs/ httpd:2.4"

#send html file to aws instance
scp -i "CS3530.pem" index.html ubuntu@ec2-18-212-183-199.compute-1.amazonaws.com:/home/ubuntu
```

![](/Users/felipecosta/Desktop/Default-Screenshots/output.png)
**Figure 11** - Pt1 Output of ./ec2.sh

![](/Users/felipecosta/Desktop/Default-Screenshots/output2.png)
**Figure 12** - Pt2 Output of ./ec2.sh

![](/Users/felipecosta/Desktop/Default-Screenshots/output3.png)
**Figure 13** - AWS file transferred
