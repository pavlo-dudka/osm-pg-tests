#!/bin/sh

if [ -e config.sh ]
  then
    source ./config.sh
fi

if [ -e temp/ua.filtered.o5m ]
  then
    mv temp/ua.filtered.o5m temp/ua.filtered.old.o5m
fi

cd bin

./osmconvert ../temp/UA.osm.pbf -o=../temp/ua.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-ways="highway=motorway =motorway_link =trunk =trunk_link =primary =primary_link =secondary =secondary_link =tertiary =tertiary_link =unclassified =residential =living_street =service =track =pedestrian =construction =footway =path" -o=../temp/ua.roads.0.o5m
./osmconvert ../temp/ua.roads.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.roads.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-ways="waterway=* or railway=*" -o=../temp/ua.waterways.0.o5m
./osmconvert ../temp/ua.waterways.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.waterways.o5m
./osmfilter ../temp/ua.o5m --keep="place=city =town =village =hamlet" -o=../temp/ua.places.0.o5m
./osmconvert ../temp/ua.places.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.places.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations=" ( admin_level=4 =6 =7 =8 ) and koatuu=*" -o=../temp/ua.boundaries.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations=" ( route=bus =trolleybus =share_taxi =tram =road ) and type=route" -o=../temp/ua.routes.0.o5m
./osmconvert ../temp/ua.routes.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.routes.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations="type=restriction =street =associatedStreet" -o=../temp/ua.relations.0.o5m
./osmconvert ../temp/ua.relations.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.relations.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations="type=multipolygon =boundary" -o=../temp/ua.multipolygons.0.o5m
./osmconvert ../temp/ua.multipolygons.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.multipolygons.o5m
./osmfilter ../temp/ua.o5m --keep="addr:street=* or addr:housename=* or addr:housenumber=* or ( building=* and name=* ) " -o=../temp/ua.address.0.o5m
./osmconvert ../temp/ua.address.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.address.o5m
./wget http://osm.org/api/0.6/node/1464223496 -O ../temp/bile.osm
./osmconvert ../temp/ua.roads.o5m ../temp/ua.waterways.o5m ../temp/ua.places.o5m ../temp/ua.boundaries.o5m ../temp/ua.routes.o5m ../temp/ua.relations.o5m ../temp/ua.multipolygons.o5m ../temp/ua.address.o5m ../temp/bile.osm -o=../temp/ua.filtered.o5m
rm ../temp/ua.roads.o5m ../temp/ua.waterways.o5m ../temp/ua.places.o5m ../temp/ua.boundaries.o5m ../temp/ua.routes.o5m ../temp/ua.relations.o5m ../temp/ua.multipolygons.o5m ../temp/ua.address.o5m
rm ../temp/ua.o5m
rm ../temp/*.0.o5m

if [ $password!='' ]
  then
    osmosis_param="user=$username password=$password host=$host:$port database=$database"
  else
    osmosis_param="user=$username host=$host:$port database=$database"
fi

if [ -e ../temp/ua.filtered.old.o5m ]
  then
    echo "ua.filtered.old.o5m exists"
    ./osmconvert ../temp/ua.filtered.old.o5m ../temp/ua.filtered.o5m --diff -o=../temp/ua.filtered.osc
    ./osmosis-latest/bin/osmosis --rxc ../temp/ua.filtered.osc --wsc $osmosis_param
  else
    echo "ua.filtered.old.o5m doesn't exist"
    ./osmosis-latest/bin/osmosis --ts $osmosis_param
    ./osmconvert ../temp/ua.filtered.o5m -o=../temp/ua.filtered.pbf
    ./osmosis-latest/bin/osmosis --rb ../temp/ua.filtered.pbf --lp --ws $osmosis_param nodeLocationStoreType="InMemory"
fi

if [ -e ../temp/ua.filtered.old.o5m ]
  then
    rm ../temp/ua.filtered.old.o5m
fi

if [ -e ../temp/ua.filtered.pbf ]
  then
    rm ../temp/ua.filtered.pbf
fi

if [ -e ../temp/ua.filtered.osc ]
  then
    rm ../temp/ua.filtered.osc
fi

cd ..

if [ ! -e results ]
  then
    mkdir results
fi

$psql_exe -f sql/osm.boundaries.sql > results/osm.boundaries.log 2>&1

cp -f data/*.txt "$pg_data_folder"
$psql_exe -f data/osm.load.data.sql

cp -f exceptions/*.exc "$pg_data_folder"
$psql_exe -f exceptions/osm.load.exceptions.sql

#rem Copying street names list
if [ ! -e $pg_data_folder"street_names/" ]
  then
    mkdir $pg_data_folder"street_names/"
fi

#cp -f ~/Dropbox/data/*.csv $pg_data_folder"street_names/"
#cp -f ~/Dropbox/data/*.txt $pg_data_folder"street_names/"
#cp -f ~/Dropbox/data/*.txt $pg_data_folder

exit 0
