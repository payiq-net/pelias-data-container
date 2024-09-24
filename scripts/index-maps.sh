#!/bin/bash

# This script indexes map data to ElasticSearch

set -e
set -x

# param1: zip name containing gtfs data
# param2: import folder name
function import_gtfs {
    unzip -o $1

    # extract feed id
    index=$(sed -n $'1s/,/\\\n/gp' feed_info.txt | grep -nx 'feed_id' | cut -d: -f1)
    prefix=$(cat feed_info.txt | sed -n 2p | cut -d "," -f $index)
    node $TOOLS/pelias-gtfs/import -d $DATA/$2 --prefix=$prefix
    # remove already parsed gtfs files
    rm *.txt
}

function import_router {
    cd $DATA/$1
    targets=(`ls *.zip`)
    for target in "${targets[@]}"
    do
        import_gtfs $target $1
    done
}

[ -z $DATA ] && exit 1

cd $SCRIPTS/
node fetchBlackList.js

import_router gtfs
echo '###### gtfs done'

node $TOOLS/openstreetmap/index
echo '###### openstreetmap done'

cd  $TOOLS/pelias-vrk
node import.js $DATA/vrk/vrk.txt
echo '###### DVV done'

node $TOOLS/pelias-nlsfi-places-importer/lib/index -d $DATA/nls-places
echo '###### NLSFI done'
