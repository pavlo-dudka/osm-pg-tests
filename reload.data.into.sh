#!/bin/sh/

if [ -e config.sh ]; then
  source ./config.sh
fi

dropdb -U postgres -w osm
createdb -O postgres -U postgres -T postgis_21_sample -w osm
$psql_exe -f sql\pg.sql

cd bin
osmconvert ../temp/ua.filtered.o5m -o=../temp/ua.filtered.pbf
osmosis --rb ../temp/ua.filtered.pbf --lp --ws user="$username" password="$password" host="$host:$port"

cd ..
$psql_exe -f sql/osm.boundaries.sql > results/osm.boundaries.log 2>&1

cd data
cp -f *.txt "$pg_data_folder"
$psql_exe -f osm.load.data.sql
cd ..

cd exceptions
cp -f *.exc "$pg_data_folder"
$psql_exe -f osm.load.exceptions.sql
cd ..

# Copying street names list
cp -f ~/Dropbox/osm/data/*.csv "`$pg_data_folder`street_names/"
cp -f ~/Dropbox/osm/data/*.txt "`$pg_data_folder`street_names/"
