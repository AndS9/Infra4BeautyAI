#!/bin/bash
set -e
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

#Installing AzureCLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Create a beauty.service for start app
wget -O beauty.service https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/service/beauty.service?token=GHSAT0AAAAAAEBTR6OWPTL3YHLHGWQIZRLG2TJ7ZFA
mv beauty.service /etc/systemd/system/beauty.service
#Add start-stop scripts
mkdir /home/developer/startup && cd /home/developer/startup
wget -O start.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/service/start.sh?token=GHSAT0AAAAAAEBTR6OWYRZJ7P6FW6AW3GOW2TJ7PHQ
wget -O stop.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/service/stop.sh?token=GHSAT0AAAAAAEBTR6OX7FL4S2O7S77IMK542TJ7QOA

#Creating .appenv from AzureKeyVault
VAULT_NAME="secretskeysval"
az login --identity

DJANGO_SECRET_KEY=$(az keyvault secret show \
  --vault-name "$VAULT_NAME" \
  --name "DjangoSecretKey" \
  --query value \
  -o tsv)

EMAIL_HOST=$(az keyvault secret show \
  --vault-name "$VAULT_NAME" \
  --name "EmailHost" \
  --query value \
  -o tsv)

EMAIL_HOST_PASSWORD=$(az keyvault secret show \
  --vault-name "$VAULT_NAME" \
  --name "EmailHostPassword" \
  --query value \
  -o tsv)
  
EMAIL_HOST_USER=$(az keyvault secret show \
  --vault-name "$VAULT_NAME" \
  --name "EmailHostUser" \
  --query value \
  -o tsv)

GOOGLE_CLIENT_ID=$(az keyvault secret show \
  --vault-name "$VAULT_NAME" \
  --name "GoogleClientId" \
  --query value \
  -o tsv)

cat > .appenv << EOF
DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
EMAIL_HOST="$EMAIL_HOST"
EMAIL_HOST_PASSWORD="$EMAIL_HOST_PASSWORD"
EMAIL_HOST_USER="$EMAIL_HOST_USER"
GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
EMAIL_PORT=587
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:8000
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
CELERY_TIMEZONE=Europe/Kyiv
EOF

systemctl daemon-reload
systemctl enable beauty.service
systemctl start beauty.service