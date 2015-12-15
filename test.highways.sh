#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

$psql_exe -f sql/osm.highways.sql
./test.translation.sh 2>&1 &
$psql_exe -f sql/osm.sharp.turns.sql -o results/sharp.turns.geojson 2>&1 &
./test.endNodes.sh 2>&1 &
$psql_exe -f sql/osm.no.highways.sql -o results/no.highways.geojson 2>&1 &
$psql_exe -f sql/osm.neighbour.names.sql -o results/osm.neighbour.names.txt 2>&1 &
$psql_exe -f sql/osm.street.names.sql -o results/osm.street.names.txt 2>&1 &
$psql_exe -f sql/osm.street.names.word.order.sql -o results/osm.street.names.word.order.txt 2>&1 &
$psql_exe -f sql/osm.restrictions.sql -o results/osm.restrictions.txt 2>&1 &
$psql_exe -f sql/osm.highway.cross_way_nodes.sql
$psql_exe -f sql/osm.highway.crossings.sql -o results/highway.crossings.geojson
$psql_exe -f sql/osm.highway.islands.sql
$psql_exe -f sql/osm.highway.islands.tertiary.sql -o results/highway.islands.tertiary.geojson
$psql_exe -f sql/osm.highway.islands.unclassified.sql -o results/highway.islands.unclassified.geojson
$psql_exe -f sql/osm.highway.islands.service.sql -o results/highway.islands.service.geojson
$psql_exe -f sql/osm.highway.islands.link.sql -o results/highway.islands.link.geojson

for job in `jobs -p`
do
    wait $job
done

exit 0
