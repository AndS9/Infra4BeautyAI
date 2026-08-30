# Infra4BeautyAI

Terraform-managed Azure infrastructure for the BeautyAI app. Provisions a resource group, virtual network, and a single Linux VM, then bootstraps the VM via a custom-script extension that installs Docker, pulls secrets from Azure Key Vault, and starts all app services as systemd units.

## Architecture

```
main.tf
├── module "network"   (modules/network)
│   ├── Virtual network + subnet
│   ├── Public IP (with DNS label)
│   └── Network Security Group (SSH, HTTP-app, ...)
└── module "compute"    (modules/compute)
    ├── NIC + NSG association
    ├── SSH public key resource
    ├── Linux VM (Ubuntu 22.04 LTS, system-assigned identity)
    ├── Managed data disk (attached at LUN 10, mounted as /beautyDB)
    ├── Custom Script Extension → runs oncreatingVM.sh on boot
    └── Key Vault role assignments (Key Vault Secrets User) for the VM identity
```
In environments folder put non-secret environment for backend(`backend.env`), frontend(`frontend.env`)

On first boot, `oncreatingVM.sh` runs on the VM and:

1. Sets the timezone to `Europe/Kyiv`.
2. Clones this repo to `/home/developer/Infra4BeautyAI`.
3. Formats and mounts the attached data disk to `/beautyDB` (`scripts/mount-disk.sh`).
4. Installs Docker (`scripts/docker-install-ubuntu.sh`).
5. Installs Python deps and pulls secrets from three Key Vaults into env files using the VM's managed identity (`scripts/get_secrets.py`, `scripts/get_server_secrets.py`):
   - Admin panel secrets → `/root/.admin.env`
   - App/DB secrets → `/root/.db.env` (backend.env values appended)
   - TLS cert/key → `/etc/nginx/ssl/server.crt` / `server.key`
6. Installs and starts all systemd units found under `services/` (`scripts/init_services.py`).
7. Seeds the database and creates a Django superuser (`scripts/init_db.sh`).

## Services

Each folder under `services/` is deployed as a systemd unit (`.service`/`.timer`) with matching `start.sh`/`stop.sh` where applicable:

| Service | Description |
|---|---|
| `backend_service` | Django backend + Celery worker/beat + Redis + Postgis DB + pgAdmin panel + AI assistant, run via `docker-compose.yaml` |
| `frontend_service` | Nginx-served frontend (`default.conf`) |
| `igorfrontend_service` | Secondary frontend container (`andriis9/igor-frontend`) |
| `dbpanel_service` | Standalone DB admin panel container (`andriis9/db-panel`) |
| `loki_service` | Loki + Grafana Alloy log stack, with provisioned dashboards/datasources |
| `webhook_listener` | Flask app (`listener.py`) listening for GitHub push webhooks on `/webhook`; restarts `backend.service` on pushes to `develop` and `frontend.service` on pushes to `frontend` |
| `shutdown_service` | Timer that shuts the VM down 60 minutes after boot |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- An [Azure account](https://azure.microsoft.com/free/) with an active subscription
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and logged in (`az login`), so Terraform can authenticate
- An SSH key pair (public key is passed to the VM for SSH access)
- Three existing Azure Key Vaults (admin, app, cert) in a known resource group

## Configuration

Set the following in a `terraform.tfvars` file(local, ssh )

| Variable | Description |
|---|---|
| `resource_group_name` / `resource_group_location` | Target resource group |
| `virtual_network_name`, `vnet_address_prefix`, `subnet_name`, `subnet_address_prefix` | Network layout |
| `public_ip_address_name`, `dns_label` | Public IP / DNS |
| `network_security_group_name`, `security_rules` | NSG rules (defaults open SSH:22 and app:8000) |
| `vm_name`, `vm_size` | VM sizing |
| `ssh_key_public` | Public key content for VM login |
| `secrets_vault_name_adm`, `secrets_vault_name_app`, `secrets_vault_name_cert`, `secrets_vault_rg` | Existing Key Vault names/RG the VM identity will read from |

To setup TLS cert/key change `./scripts/get_server_secrets.py` VAULT_URL to Azure Key Vault with yours `server-crt` and `server-key`.

 ## Usage

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Outputs after apply:

- `resource_group` — the created resource group
- `public_ip` — the VM's public IP
- `public_domain` — the DNS label assigned to the public IP

SSH in as the `developer` user once the extension has finished running (VM provisioning + service startup can take a few minutes after `apply` completes).

## Repo layout

```
.
├── main.tf, variables.tf, outputs.tf, provider.tf
├── modules/
│   ├── network/     # VNet, subnet, public IP, NSG
│   └── compute/     # VM, disk, extension, Key Vault role assignments
├── oncreatingVM.sh          # VM bootstrap entrypoint
├── scripts/                 # Bootstrap helper scripts
├── services/                 # systemd units + docker-compose files per service
├── environments/             # Non-secret env fragments merged into runtime env files
└── requirements.txt          # Python deps for bootstrap scripts
```