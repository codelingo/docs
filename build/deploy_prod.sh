#!/bin/bash

set -e

az login --service-principal  --username $USERNAME --password $PASSWORD --tenant $TENANT

az aks get-credentials --resource-group DefaultResourceGroup-WUS --name production

helm upgrade --install docs build/chart -f build/chart/values.yaml --wait
