#!/bin/bash

set -e
set -x

if [ -z "$DIGITRANSIT_SUBSCRIPTION_KEY" ]; then
  echo "Variable DIGITRANSIT_SUBSCRIPTION_KEY is not set"
  exit 1
fi

docker build --tag payiq/pelias-data-container-tools --build-arg ELASTICSEARCH_HOST=host.docker.internal:9200 --build-arg DIGITRANSIT_SUBSCRIPTION_KEY=$DIGITRANSIT_SUBSCRIPTION_KEY -f Dockerfile.tools .
docker run -it payiq/pelias-data-container-tools

