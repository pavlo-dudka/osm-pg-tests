#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

dropdb -U $username -p $port -w $database
# createdb -O $username -U $username -p $port -T postgis_21_sample -w osm
createdb -O postgres -U $username -p $port -T template0 -w $database -E UTF8
psql -U $username -p $port -d $database -c "CREATE EXTENSION postgis;"
$psql_exe -f sql/pg.sql

exit 0
