#!/bin/bash

DEBIAN_FRONTEND=noninteractive #Disactivate Interctive windows during installation apt packages

apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings

#Installing docker-daemon and tools
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker developer

#Cloning git repos with app
cd /home/developer
git clone -b develop https://github.com/KLUZOO/beauty-ai-platform
cd beauty-ai-platform/backend/
wget -O beauty.service https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/service/beauty.service?token=GHSAT0AAAAAAEBTR6OWBP7LISNLPQMLJGO62TJC6KQ
# create a service for the app via systemctl
mv beauty.service /etc/systemd/system/
#systemctl daemon-reload
#systemctl start todoapp
#systemctl enable todoapp