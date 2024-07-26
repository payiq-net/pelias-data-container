#!/bin/bash

# This script creates pelias index

set -e
set -x

[ -z $DATA ] && exit 1

cd $TOOLS/pelias-schema/
node scripts/create_index
