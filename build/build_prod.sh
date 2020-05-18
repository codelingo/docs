#!/usr/bin/env bash

echo $GOOGLE_AUTH_JSON | docker login -u _json_key --password-stdin https://us.gcr.io

make buildprod
