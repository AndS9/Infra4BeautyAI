#!/bin/bash
set -e

#Mounting disk
wget https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/develop/scripts/mount-disk.sh
/bin/bash ./mount-disk.sh

#Installing docker
wget https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/develop/scripts/docker-install-ubuntu.sh
/bin/bash ./docker-install-ubuntu.sh

#Environment variables for docker
wget https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/develop/scripts/get-sercrets.sh
/bin/bash ./get-sercrets.sh


#Create a beauty.service for start app
wget -O beauty.service https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/beauty.service
mv beauty.service /etc/systemd/system/beauty.service
mkdir /home/developer/startup && cd /home/developer/startup
wget -O start.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/start.sh
wget -O stop.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/stop.sh

systemctl daemon-reload
systemctl enable beauty.service
systemctl start beauty.service