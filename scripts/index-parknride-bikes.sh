#!/bin/bash

# This script indexes parknride and bikes to ElasticSearch

set -e
set -x

[ -z $DATA ] && exit 1

node $TOOLS/bikes-pelias/import "$APIURL"routing/v2/routers/finland/index/graphql$APIKEYPARAMS
node $TOOLS/bikes-pelias/import "$APIURL"routing/v2/routers/waltti/index/graphql$APIKEYPARAMS
echo '###### city bike station loading done'

node $TOOLS/parking-areas-pelias/import "$APIURL"routing/v2/routers/hsl/index/graphql$APIKEYPARAMS liipi
echo '###### park & ride location loading done'
