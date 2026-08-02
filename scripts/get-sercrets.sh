#Installing AzureCLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

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
