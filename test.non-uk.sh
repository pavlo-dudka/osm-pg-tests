#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

$psql_exe -f sql/osm.non-uk.sql
$psql_exe -f sql/osm.non-uk.2.sql -o results/non-uk.geojson 2>&1 &
$psql_exe -f sql/osm.non-uk.txt.sql -o results/osm.non-uk.txt /dev/null 2>&1 & 

exit 0
