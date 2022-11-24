#!/bin/bash
# Hardware requirements: AWS Linux 2 with mimum t2.micro type instance & port 8080 should be allowed on the security groups
sudo yum update –y
sudo useradd ansadmin
sudo passwd ansadmin
sudo echo ansadmin:ansadmin | chpasswd
sudo sed -i "s/.*PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo service sshd restart
sudo echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sudo service sshd restart
sudo usermod -aG wheel ansadmin
sudo amazon-linux-extras install tomcat8.5 -y
sudo systemctl enable tomcat
sudo systemctl start tomcat