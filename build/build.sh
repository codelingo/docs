#!/usr/bin/env bash

# Log in to Docker with service principal credentials
docker login codelingo.azurecr.io --username $USERNAME --password $PASSWORD
make buildimage
