import sys

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

VAULT_URL = sys.argv[1]
env_path = sys.argv[2]

def convert_name(name: str) -> str:
    return name.replace("-", "_").upper()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python get_secrets.py <VAULT_URL> <output_file>")
        sys.exit(1)
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=VAULT_URL, credential=credential)

    #Write secrets to the specified file
    with open(env_path, "a") as f:
        for secret_properties in client.list_properties_of_secrets():
            secret_name = secret_properties.name
            secret = client.get_secret(secret_name)
            f.write(f"{convert_name(secret_name)}={secret.value}\n")