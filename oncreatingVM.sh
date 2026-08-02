#!/bin/bash
set -e



git clone https://github.com/AndS9/Infra4BeautyAI
mv Infra4BeautyAI /home/developer/Infra4BeautyAI

cd /home/developer/Infra4BeautyAI/scripts
#Mounting disk
/bin/bash ./mount-disk.sh

#Installing docker
/bin/bash ./docker-install-ubuntu.sh

#Environment variables for docker
/bin/bash ./get-sercrets.sh


#Create a beauty.service for start app
mv /home/developer/Infra4BeautyAI/beauty_service/beauty.service /etc/systemd/system/beauty.service

systemctl daemon-reload
systemctl enable beauty.service
systemctl start beauty.service