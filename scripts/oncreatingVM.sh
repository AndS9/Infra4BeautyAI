#!/bin/bash
set -e

#Mounting disk
wget https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/develop/scripts/mount-disk.sh
/bin/bash ./mount-disk.sh

#Installing docker
wget https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/develop/scripts/docker-install-ubuntu.sh
/bin/bash ./docker-install-ubuntu.sh

#Installing AzureCLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Create a beauty.service for start app
wget -O beauty.service https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/beauty.service
mv beauty.service /etc/systemd/system/beauty.service
mkdir /home/developer/startup && cd /home/developer/startup
wget -O start.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/start.sh
wget -O stop.sh https://raw.githubusercontent.com/AndS9/Infra4BeautyAI/refs/heads/main/stop.sh
chmod u+x start.sh stop.sh
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