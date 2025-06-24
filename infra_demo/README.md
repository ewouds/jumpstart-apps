# K3s Cluster on Azure VMs

This Bicep template deploys a K3s cluster consisting of one master node and two worker nodes on Azure VMs.

## Requirements

- Azure subscription
- Azure CLI
- Visual Studio Code with Azure Bicep extension

## Infrastructure Overview

The deployment creates:

- 1 Virtual Network with 1 subnet
- 3 Ubuntu 22.04 VMs (1 master + 2 workers)
- Public IP addresses for each VM
- Network Security Groups with required ports open
- Network interfaces

## VM Specifications

- Size: Standard_B2s (2 vCPUs, 4GB RAM)
- OS: Ubuntu 22.04 LTS
- Disk: Standard SSD

## Deployment

1. Set your Azure subscription:

```powershell
az account set --subscription <your-subscription-id>
```

2. Create a resource group:

```powershell
az group create --name <resource-group-name> --location eastus
```

3. Deploy the Bicep template:

```powershell
az deployment group create --resource-group <resource-group-name> --template-file main.bicep --parameters main.parameters.json --parameters adminPassword=<your-secure-password>
```

## Post-Deployment

After deployment:

1. Connect to the master node using SSH
2. Get the node token from `/var/lib/rancher/k3s/server/node-token`
3. Update the worker.sh script with the master node's IP and token
4. Run the worker script on worker nodes

## Security Notes

- Default username is 'k3sadmin'
- Remember to change the admin password in parameters file
- The deployment opens required K3s ports (6443, 8472, 10250)
- SSH access is enabled on all nodes
