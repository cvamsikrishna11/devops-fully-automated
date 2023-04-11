#!/bin/bash
# Hardware requirements: Amazon Linux 2 Kernel 5.10 AMI with mimum t2.medium type instance & port 8080(jenkins), 9100 (node-exporter) should be allowed on the security groups
#Note: Dont use the latest EC2 Linux of 2023 as it doesnt have amazon-linux-extras which was used in the Jenkins installation as per the old AMI.
# Installing Jenkins
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key # Note: Refer this link to change this key line frequently https://pkg.jenkins.io/redhat-stable/
sudo yum upgrade
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Installing Git
sudo yum install git -y

# Installing maven - commented out as usage of tools explanation is required.
# sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
# sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
# sudo yum install -y apache-maven

# Java installation
# sudo yum install java-1.8.0-openjdk -y
# sudo amazon-linux-extras install java-openjdk11 -y

# Installing Ansible
sudo amazon-linux-extras install ansible2 -y
sudo yum install python-pip -y
sudo pip install boto3
sudo useradd ansadmin
sudo echo ansadmin:ansadmin | chpasswd
sudo sed -i "s/.*#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
sudo sed -i "s/.*#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = aws_ec2/g" /etc/ansible/ansible.cfg
sudo ansible-galaxy collection install amazon.aws

# node-exporter installations
sudo useradd --no-create-home node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

# setup the node-exporter dependencies
sudo yum install git -y
sudo git clone -b installations https://github.com/cvamsikrishna11/devops-fully-automated.git /tmp/devops-fully-automated
sudo cp /tmp/devops-fully-automated/prometheus-setup-dependencies/node-exporter.service /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter

# Setup terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform