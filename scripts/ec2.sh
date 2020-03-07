#!/bin/bash


./3ssh.sh | tee index.html

ssh -t -i "CS3530.pem" ubuntu@ec2-18-212-183-199.compute-1.amazonaws.com \
	"sudo docker run -dit --name final-project -p 8080:80 -v '/home/ubuntu':/usr/local/apache2/htdocs/ httpd:2.4"

scp -i "CS3530.pem" index.html ubuntu@ec2-18-212-183-199.compute-1.amazonaws.com:/home/ubuntu


#format txt to html ?
# scp output.txt to aws 
