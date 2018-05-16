#!/usr/bin/env bash

# make sure you have private key added to access the EC2

instance=52.27.143.86
ssh ubuntu@$instance "sudo rm -rf /site"
ssh ubuntu@$instance "sudo mv ~/site /"
ssh ubuntu@$instance "sudo chown -R nginx:nginx /site"

