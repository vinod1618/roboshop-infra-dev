#!/bin/bash
dnf install ansible -y

component=$1
cd /home/ec2-user
git clone https://github.com/vinod1618/ansible-roboshop-roles-tf.git

cd ansible-roboshop-roles-tf 
ansible-playbook -e component=$component roboshop.yaml