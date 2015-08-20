#!/bin/sh

if [ -e config.sh ]; then
  source ./config.sh
fi

dropdb -U $username -w osm
# createdb -O $username -U $username -T postgis_21_sample -w osm
createdb -O postgres -U $username -T template0 -w osm -E UTF8
psql -d osm -c "CREATE EXTENSION postgis;"
$psql_exe -f sql/pg.sql

cd bin

if [ $password!='' ]
  then
    osmosis_param=`user="$username" password="$password" host="$host:$port"`
  else
    osmosis_param=`user="$username" host="$host:$port"`
fi

./osmconvert ../temp/ua.filtered.o5m -o=../temp/ua.filtered.pbf
osmosis --rb ../temp/ua.filtered.pbf --lp --ws $osmosis_param

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
if [ ! -e $pg_data_folder"street_names/" ]
  then
    mkdir $pg_data_folder"street_names/"
fi

cp -f ~/Dropbox/data/*.csv `$pg_data_folder`"street_names/"
cp -f ~/Dropbox/data/*.txt `$pg_data_folder`"street_names/"
