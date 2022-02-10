# aks-vault-demo
Using Terraform to deploy an AKS cluster and Helm to deploy HashiCorp Vault

# Prerequisites
You need to have an Azure subscription where the AKS cluster will be deployed and a Linux machine with the following tools installed:
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [helm](https://helm.sh/docs/intro/install/)
- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
- jq:
```
sudo apt install jq
```

# Installation

## AKS Cluster Setup
Run the terraform installation script.  
You will need to login to your Azure account.  
The script will create a service principal on Azure, deploy the Terraform template and set the kubeconfig accordingly:
```
./terraforminstall.sh
```
### Verify deployment
Use kubectl to verify you can access the cluster:
```
kubectl get nodes
```
You should see 2 nodes in the cluster
## Vault deployment
Run the vaultinstall.sh script to install the Helm chart for Vault, you can add an argument which will be the name of the Helm release.  
The release name can only contain lowercase letters and numbers, and must start with a letter, max length is 24.  
Default is demo.
```
./vaultinstall.sh demo
```
The Vault will be initialized and unsealed. The root token will be displayed in the script output.  
Port-forwarding will start in order to access the UI.  
Open your browser and browse to http://localhost:8200  
Enter the root token to login.


# Cleanup
If you chose a custom release name, replace "demo" with your release name in all the commands below.  
Uninstall the Helm release:
```
helm delete demo
```
Delete pvc:
```
kubectl delete pvc data-demo-vault-0
```
Delete the service principal
```
az ad sp delete --id $(cat sp.json | jq -r ".appId")
```
Remove vault information
```
rm cluster-keys.json status.json sp.json
```
