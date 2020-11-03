#!/bin/bash

set -e

codeship_google authenticate

gcloud container clusters get-credentials production --zone us-west2-b

helm upgrade docs build/chart -f build/chart/prod-values.yaml --wait
