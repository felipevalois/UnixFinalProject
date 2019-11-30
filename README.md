# Felipe Costa - CS3530 Final Project

## Manual Process

### VMs Deployment
Three Vms were deployed on VMWare Fusion: Master(Debian), Node1(Ubuntu) and Node2(CentOS) using the following images.

[1] [Debian 10.2.0](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.2.0-amd64-netinst.iso)

[2] [Ubuntu 18.04.3](http://releases.ubuntu.com/18.04/ubuntu-18.04.3-desktop-amd64.iso)

[3] [CentOS 7.7.1908](http://mirror.mobap.edu/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso)

### Dependencies for Project
INSTALLING DEPENDENCIES FOR PROJECT
1)VMWare TOOLS
su -
apt-get update
apt-get upgrade
apt-get install build-essential module-assistant
*on VMWARE MENU*
Virtual Machine -> install VMWare Tools
Open mounted disk containing compressed file
extract compressed file to user's home dir
*back to cli*
cd vmware-tools-distrib
sudo ./vmware-install.pl
reboot


2)Net-tools (ifconfig)
sudo apt-get install net-tools (ifconfig) / yum install net-tools

3)SSH service
sudo apt-get install openssh-server -y (centos alreade installed by default)

4)SSH Key
Generated key-pair to ssh into Nodes without password authentication, this is not only more secure but also works bette with scripts

on master
ssh-keygen
ssh-copy-id user2@192.168.1.20
ssh-copy-id user3@192.168.1.30

Edited the file /etc/ssh/sshd_config (both nodes)
Changed line ‘#PasswordAuthentication yes’ to ‘PasswordAuthentication no’
sudo service sshd restart

 ### Users
DEBIAN 
su -
adduser user1
usermod -aG sudo user1
reboot

UBUNTU
sudo adduser user2
usermod -aG sudo user2

CENTOS
adduser user3
usermod -aG wheel user3


### Network Configuration
Master (Debian)
Virtual Machine -> Settings -> Add Device -> Network Adapter -> Private to my Mac 
sudo ifconfig ens37 192.168.1.10 netmask 255.255.255.0
dhclient -r
dhclient
vim /etc/network/interfaces
append following lines:
“
auto ens37
iface ens37 inet static
  address 192.168.1.10
  netmask 255.255.255.0
"
sudo reboot

Node1 (Ubuntu)
change from share w mac to private
sudo ifconfig ens33 192.168.1.20 netmask 255.255.255.0
dhclient -r
dhclient
vim /etc/network/interfaces
append following lines:
“
auto ens33
iface ens33 inet static
  address 192.168.1.20
  netmask 255.255.255.0
"
sudo reboot

Node2 (CentOS)
change from share w mac to private
ip address sudoadd 192.168.1.30 dev ens33
sudo vi /etc/sysconfig/network-scripts/ifcfg-ens33
SCREENSHOT 




### AWS Instance




## Local Process
1 hostname
2 cat /etc/os-release (then cut to get only line starting with name)
3 uname --m
4 basename -a /sys/class/net/*
5 ifconfig + cut ...
6 who or w
7 
8
9
10
11
12
13?
14?
15?

## Remote Process

