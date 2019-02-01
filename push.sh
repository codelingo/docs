#!/usr/bin/env bash

tag=$1
if [ -z "$tag" ]
then
    tag=$(git rev-parse --verify --short HEAD)
fi

set -e

registry=531831122766.dkr.ecr.us-west-2.amazonaws.com
image=docs

mkdocs build

docker build -t $registry/$image:$tag .
docker push $registry/$image:$tag

JSON='{"image": "'"$registry/$image"'", "tag": "'"$tag"'"}'
printf '%s' "$JSON"
