#!/bin/bash
az login
az ad sp create-for-rbac -n "Terraform" > sp.json
APPID=$(cat sp.json | jq -r ".appId")
PASSWORD=$(cat sp.json | jq -r ".password")
echo "appId = "\"$APPID"\"" > src/tf/terraform.tfvars
echo "password = "\"$PASSWORD"\"" >> src/tf/terraform.tfvars

cd src/tf/
terraform init
terraform plan
terraform apply -auto-approve
KUBECONFIG="$(pwd)/kubeconfig"
if ! test -f "$KUBECONFIG"
then
	echo "No kubeconfig, Terraform apply failed?"
	exit
fi
FILE=~/.kube/config
if test -f "$FILE"
then
	echo "kubeconfig already exist, making a backup"
	cp $FILE "$FILE.bak"
fi
echo "Copying kubeconfig to $FILE"
cp kubeconfig $FILE

