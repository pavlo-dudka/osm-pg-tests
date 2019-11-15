#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

$psql_exe -f sql/osm.street.relations.sql -o results/street.relations.geojson 2>&1 & #"street.relations"
$psql_exe -f sql/osm.street.relations.m.sql -o results/street.relations.m.geojson 2>&1 & #"street.relations.m"
$psql_exe -f sql/osm.street.relations.0.sql
$psql_exe -f sql/osm.street.relations.n.sql -o results/street.relations.n.geojson 2>&1 & #"street.relations.n"
$psql_exe -f sql/osm.street.relations.o.sql -o results/street.relations.o.geojson 2>&1 & #"street.relations.o"
$psql_exe -f sql/osm.street.relations.o.bld.sql -o results/street.relations.ob.geojson 2>&1 & #"street.relations.ob"
$psql_exe -f sql/osm.street.relations.o.str.sql -o results/street.relations.os.geojson 2>&1 & #"street.relations.os"


for job in `jobs -p`
do
    wait $job
done

exit 0