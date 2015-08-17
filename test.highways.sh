#!/bin/sh

if [ -e config.sh ]; then
  source ./config.sh
fi

$psql_exe -f sql/osm.highways.sql
./test.translation.sh
$psql_exe -f sql/osm.sharp.turns.sql -o results/sharp.turns.geojson
./test.endNodes.sh
$psql_exe -f sql/osm.no.highways.sql -o results/no.highways.geojson
$psql_exe -f sql/osm.neighbour.names.sql -o results/osm.neighbour.names.txt
$psql_exe -f sql/osm.street.names.sql -o results/osm.street.names.txt
$psql_exe -f sql/osm.street.names.word.order.sql -o results/osm.street.names.word.order.txt
$psql_exe -f sql/osm.restrictions.sql -o results/osm.restrictions.txt
$psql_exe -f sql/osm.highway.cross_way_nodes.sql
$psql_exe -f sql/osm.highway.crossings.sql -o results/highway.crossings.geojson
$psql_exe -f sql/osm.highway.islands.sql
$psql_exe -f sql/osm.highway.islands.tertiary.sql -o results/highway.islands.tertiary.geojson
$psql_exe -f sql/osm.highway.islands.unclassified.sql -o results/highway.islands.unclassified.geojson
$psql_exe -f sql/osm.highway.islands.service.sql -o results/highway.islands.service.geojson

exit 0
