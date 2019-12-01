#!/usr/bin/env bash
set -e
# run this script with the target ecr repo and the latest will be tagged with this.

curr_date=$(date +'%s')
docker build -t $1:$curr_date docker

docker tag $1:$curr_date $1:latest

$(aws ecr get-login --region eu-west-1 --no-include-email)
docker push $1:$curr_date
docker push $1:latest

