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

#Add init_db script
mv /home/developer/Infra4BeautyAI/scripts/init_db.sh /home/developer/init_db.sh
chmod u+x /home/developer/init_db.sh

# Start all services in services directory
/bin/python3 /home/developer/Infra4BeautyAI/scripts/init_services.py
/bin/bash /home/developer/Infra4BeautyAI/scripts/init_db.sh
# #Create a beauty.service for start app
# mv /home/developer/Infra4BeautyAI/backend_service/backend.service /etc/systemd/system/backend.service
# cd /home/developer/Infra4BeautyAI/backend_service
# chmod u+x ./start.sh ./stop.sh

# #Create a beauty-frontend.service for start frontend
# mv /home/developer/Infra4BeautyAI/frontend_service/frontend.service /etc/systemd/system/frontend.service
# cd /home/developer/Infra4BeautyAI/frontend_service
# chmod u+x ./start.sh ./stop.sh

# #Webhook listener
# mv /home/developer/Infra4BeautyAI/webhook_listener/webhook.service /etc/systemd/system/webhook.service

# # Add beauty-logs.service
# mv /home/developer/Infra4BeautyAI/loki_service/loki.service /etc/systemd/system/loki.service
# cd /home/developer/Infra4BeautyAI/loki_service
# chmod u+x ./start.sh ./stop.sh



# # Add igorfrontend_service and shutdown_service
# mv /home/developer/Infra4BeautyAI/igorfrontend_service/igorfrontend.service /etc/systemd/system/igorfrontend.service
# mv /home/developer/Infra4BeautyAI/dbpanel_service/dbpanel.service /etc/systemd/system/dbpanel.service
# mv /home/developer/Infra4BeautyAI/shutdown_service/shutdown.service /etc/systemd/system/shutdown.service
# mv /home/developer/Infra4BeautyAI/shutdown_service/shutdown.timer /etc/systemd/system/shutdown.timer


# # Starting services
# systemctl daemon-reload
# systemctl enable backend.service frontend.service webhook.service loki.service shutdown.timer igorfrontend.service dbpanel.service
# systemctl start backend.service frontend.service webhook.service loki.service shutdown.timer igorfrontend.service dbpanel.service
