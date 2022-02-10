#!/bin/bash

# errors should break the execution
set -e

# Download gtfs stop data

echo 'Loading GTFS data from api.digitransit.fi...'

cd $DATA
mkdir -p gtfs
mkdir -p openstreetmap

URL="http://api.digitransit.fi/routing-data/v2/"

# param1: service name
# param2: optional basic auth string
function load_gtfs {
    NAME="router-"$1
    ZIPNAME=$NAME.zip
    curl -sS -O --fail $2 $URL$1/$ZIPNAME
    unzip -o $ZIPNAME && rm $ZIPNAME
    mv $NAME/*.zip gtfs/
}

load_gtfs finland
# use already validated osm data from our own data api
mv router-finland/*.pbf openstreetmap/

load_gtfs waltti
load_gtfs hsl

if [[ -v GTFS_AUTH ]]; then
    NAME="router-waltti-alt"
    ZIPNAME=$NAME.zip
    curl -sS -O --fail -u $GTFS_AUTH "http://dev-api.digitransit.fi/routing-data/v3/waltti-alt/$ZIPNAME"
    unzip -o $ZIPNAME && rm $ZIPNAME
    mv $NAME/*.zip gtfs/
fi

echo '##### Loaded GTFS data'
