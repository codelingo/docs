#!/bin/bash

set -e

codeship_google authenticate

gcloud container clusters get-credentials staging --region us-west2-a

helm upgrade docs build/chart -f build/chart/staging-values.yaml --wait
