#!/bin/bash
set -e

apt-get update

apt-get upgrade -y

apt-get install ssh net-tools dnsutils curl wget screenfetch -y

apt-get install vim vim-doc vim-scripts -y

apt-get install tcpdump nmap irssi irssi-scripts -y

apt-get install htop tree ssh fail2ban rsync git -y

apt-get install tmux screen nload iotop wget lynx -y

apt-get install shellcheck bash-completion -y

apt-get install python python3 python-pip python3-pip -y

apt-get install build-essential -y
