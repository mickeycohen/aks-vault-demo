#!/bin/bash
if [ $# -eq 0 ]
then
	echo "Release name not provided, using 'demo'"
	HELMRELEASE="demo"
else
	HELMRELEASE=$(echo "$1" | awk '{print tolower($0)}' | cut -c -24)
fi
echo "Installing Helm release"
helm install $HELMRELEASE src/helm/mickey --dependency-update
sleep 3
echo "Waiting for vault pod to be ready"
kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l statefulset.kubernetes.io/pod-name=$HELMRELEASE-vault-0 --timeout=300s
echo "Getting vault status"
kubectl exec $HELMRELEASE-vault-0 -- vault status -format=json > status.json
INITIALIZED=$(cat status.json | jq -r ".initialized")
echo $INITIALIZED
if [ $INITIALIZED == "true" ]
then
	echo "Vault already initialized"
else
	echo "Initializing vault and saving keys"
	kubectl exec $HELMRELEASE-vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
fi
SEALED=$(cat status.json | jq -r ".sealed")
if [ $SEALED == "true" ]
then
        echo "Vault is sealed, unsealing it"
	KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[0]")
	kubectl exec $HELMRELEASE-vault-0 -- vault operator unseal $KEY
	ROOTTOKEN=$(cat cluster-keys.json | jq -r ".root_token")
	echo "Root token is $ROOTTOKEN"

else
        echo "Vault is already unsealed"
fi
echo "Starting port forwarding for vault UI"
echo "Open your browser and go to http://localhost:8200"
kubectl port-forward svc/$HELMRELEASE-vault-ui 8200:8200
