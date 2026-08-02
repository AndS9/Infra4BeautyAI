#!/bin/bash
set -e

#apt update && apt upgrade -y

git clone https://github.com/AndS9/Infra4BeautyAI
mv Infra4BeautyAI /home/developer/Infra4BeautyAI

cd /home/developer/Infra4BeautyAI/scripts
#Mounting disk
/bin/bash ./mount-disk.sh

#Installing docker
/bin/bash ./docker-install-ubuntu.sh

#Environment variables for docker
/bin/bash ./get-secrets.sh


#Create a beauty.service for start app
mv /home/developer/Infra4BeautyAI/beauty_service/beauty.service /etc/systemd/system/beauty.service
cd /home/developer/Infra4BeautyAI/beauty_service
#chmod u+x ./start.sh ./stop.sh

#Create a beauty-frontend.service for start frontend
mv /home/developer/Infra4BeautyAI/frontend_service/frontend.service /etc/systemd/system/frontend.service
cd /home/developer/Infra4BeautyAI/frontend_service
#chmod u+x ./start.sh ./stop.sh

systemctl daemon-reload
systemctl enable beauty.service frontend.service
systemctl start beauty.service frontend.service