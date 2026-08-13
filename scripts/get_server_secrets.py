import sys

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

VAULT_URL = "https://keyvaultbeautycert.vault.azure.net/"

if __name__ == "__main__":
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=VAULT_URL, credential=credential)

    #Write secrets to the specified file
    with open("/etc/nginx/ssl/server.crt", "w") as f:
        secret = client.get_secret("server-crt")
        f.write(secret.value)
    with open("/etc/nginx/ssl/server.key", "w") as f:
        secret = client.get_secret("server-key")
        f.write(secret.value)