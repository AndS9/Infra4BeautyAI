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



#Environment variables and secrets
cd /home/developer/Infra4BeautyAI/scripts

#Admin panel secrets
/bin/python3 ./get_secrets.py https://keyvaultadmpanel.vault.azure.net/ \
    /root/.admin.env

#database and backend secrets
/bin/python3 ./get_secrets.py https://keyvaultbeautyapp.vault.azure.net/ \
   /root/.db.env

#add backend environments to env-file
cat /home/developer/Infra4BeautyAI/environments/backend.env >> \
    /root/.db.env


# Add server.crt and server.key
mkdir -p /etc/nginx/ssl
/bin/python3 /home/developer/Infra4BeautyAI/scripts/get_server_secrets.py

#Add flushdb script
mv /home/developer/Infra4BeautyAI/scripts/flushdb.sh /home/developer/flushdb.sh
chmod u+x /home/developer/flushdb.sh

# Start all services in services directory
/bin/python3 /home/developer/Infra4BeautyAI/scripts/init_services.py

#Initialize database
chmod u+x /home/developer/Infra4BeautyAI/scripts/init_db.sh
/bin/bash /home/developer/Infra4BeautyAI/scripts/init_db.sh
