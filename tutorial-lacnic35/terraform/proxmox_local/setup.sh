#!/bin/sh

sudo apt -y install git ansible figlet
cd /home/ubuntu
git clone https://github.com/LACNOG/dns-dnssec-labs.git

# 
cd dns-dnssec-labs/tutorial-lacnic35
sudo ansible-playbook -i hosts_tutorial.txt site-lab-env.yml

# banner
echo "Maquina lista" | figlet -w 120

