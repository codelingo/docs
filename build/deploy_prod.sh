#!/bin/bash

set -e

codeship_google authenticate

gcloud container clusters get-credentials production --region us-west1

helm upgrade docs build/chart -f build/chart/prod-values.yaml --wait
