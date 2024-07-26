#!/bin/bash

set -e

#==============
# Download data
#==============

$SCRIPTS/vrk-loader.sh
$SCRIPTS/osm-loader.sh
# $SCRIPTS/nlsfi-loader.sh
$SCRIPTS/gtfs-loader.sh

cd $TOOLS
git clone --single-branch https://github.com/hsldevcom/pelias-data-container tpdc
mv tpdc/wof_data $DATA/
rm -rf tpdc
