#!/bin/bash

# This script downloads new data and indexes it into ES
# It can be applied to update a running ElasticSearch instance.
# Set these env variables before running this script locally:
#   TOOLS - path to data indexing tool folder. All required git projects must be pre-installed.
#   DATA - data dir path.
#   SCRIPTS - path to pelias-data-container scripts
# Also, a valid pelias.json configuration must be present. It's data paths must match the DATA env variable.

# errors should break the execution

set -e

export SCRIPTS=${SCRIPTS:-$TOOLS/scripts}
#schema script runs only from current dir
cd $TOOLS/pelias-schema/
node scripts/create_index

cd $SCRIPTS/
node fetchBlackList.js

if [ "$BUILDER_TYPE" = "dev" ]; then
    APIURL="https://dev-api.digitransit.fi/"
else
    APIURL="https://api.digitransit.fi/"
fi

if [ -n "${API_SUBSCRIPTION_QUERY_PARAMETER_NAME}" ]; then
   APIKEYPARAMS='?'"$API_SUBSCRIPTION_QUERY_PARAMETER_NAME"'='"$API_SUBSCRIPTION_TOKEN"
fi

echo "###### Using $APIURL data"

source $SCRIPTS/load-all.sh

#=================
# Index everything
#=================

source $SCRIPTS/index-maps.sh

export APIURL
source $SCRIPTS/index-parknride-bikes.sh

# node $TOOLS/pelias-nlsfi-places-importer/lib/index -d $DATA/nls-places
# echo '###### nlsfi places done'

#cleanup
rm -rf $DATA/vrk
rm -rf $DATA/openstreetmap
rm -rf $DATA/nls-places
rm -rf $DATA/router-waltti
rm -rf $DATA/router-waltti-alt
rm -rf $DATA/router-finland
rm -rf $DATA/router-hsl
rm -rf $DATA/gtfs
rm -rf $DATA/wof_data
