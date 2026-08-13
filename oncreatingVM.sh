#!/bin/bash
set -e

timedatectl set-timezone Europe/Kyiv

#apt update && apt upgrade -y
git clone https://github.com/AndS9/Infra4BeautyAI
mv Infra4BeautyAI /home/developer/Infra4BeautyAI

cd /home/developer/Infra4BeautyAI/scripts
#Mounting disk
/bin/bash ./mount-disk.sh

#Installing docker
/bin/bash ./docker-install-ubuntu.sh



sudo apt install -y python3-pip
pip install -r /home/developer/Infra4BeautyAI/requirements.txt


#Create a beauty.service for start app
mv /home/developer/Infra4BeautyAI/backend_service/backend.service /etc/systemd/system/backend.service
cd /home/developer/Infra4BeautyAI/backend_service
chmod u+x ./start.sh ./stop.sh

#Create a beauty-frontend.service for start frontend
mv /home/developer/Infra4BeautyAI/frontend_service/frontend.service /etc/systemd/system/frontend.service
cd /home/developer/Infra4BeautyAI/frontend_service
chmod u+x ./start.sh ./stop.sh

#Webhook listener
mv /home/developer/Infra4BeautyAI/webhook_listener/webhook.service /etc/systemd/system/webhook.service

# Add beauty-logs.service
mv /home/developer/Infra4BeautyAI/loki_service/loki.service /etc/systemd/system/loki.service
cd /home/developer/Infra4BeautyAI/loki_service
chmod u+x ./start.sh ./stop.sh

#Add flushdb script
mv /home/developer/Infra4BeautyAI/scripts/flushdb.sh /home/developer/flushdb.sh
chmod u+x /home/developer/flushdb.sh


#Environment variables and secrets
cd /home/developer/Infra4BeautyAI/scripts
#Admin panel secrets
/bin/python3 ./get_secrets.py https://keyvaultadmpanel.vault.azure.net/ \
    /root/.admin.env
#database and backend secrets
/bin/python3 ./get_secrets.py https://keyvaultbeautyapp.vault.azure.net/ \
   /root/.db.env
#backend secrets
cat /home/developer/Infra4BeautyAI/environments/backend.env >> \
    /root/.db.env

# Add server.crt and server.key
mkdir -p /etc/nginx/ssl
/bin/python3 /home/developer/Infra4BeautyAI/scripts/get_server_secrets.py

# Starting services
systemctl daemon-reload
systemctl enable backend.service frontend.service webhook.service loki.service
systemctl start backend.service frontend.service webhook.service loki.service
