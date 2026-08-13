import os
import sys

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

VAULT_URL = "https://keyvaultbeautycert.vault.azure.net/"

def format_secret(content: str, header: str, footer: str) -> str:
    body = content[len(header):-len(footer)]
    body = body.replace(" ", "\n")
    return header + body + footer

if __name__ == "__main__":
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=VAULT_URL, credential=credential)

    cert = client.get_secret("server-crt").value
    key = client.get_secret("server-key").value
    cert = format_secret(cert, "-----BEGIN CERTIFICATE-----", 
                             "-----END CERTIFICATE-----")
    
    key = format_secret(key, "-----BEGIN PRIVATE KEY-----",
                             "-----END PRIVATE KEY-----")
    
    #Write secrets to the specified file
    with open("/etc/nginx/ssl/server.crt", "w") as f:
        f.write(cert)
    with open("/etc/nginx/ssl/server.key", "w") as f:
        f.write(key)
    os.chmod("/etc/nginx/ssl/server.crt", 0o644)
    os.chmod("/etc/nginx/ssl/server.key", 0o600)