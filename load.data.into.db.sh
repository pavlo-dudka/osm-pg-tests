#!/bin/bash

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
./osmfilter ../temp/ua.o5m --keep= --keep-ways="waterway=* or railway=* or aeroway=*" -o=../temp/ua.waterways.0.o5m
./osmconvert ../temp/ua.waterways.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.waterways.o5m
./osmfilter ../temp/ua.o5m --keep="place=city =town =village =hamlet" -o=../temp/ua.places.0.o5m
./osmconvert ../temp/ua.places.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.places.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations=" ( admin_level=4 =6 =7 =8 ) and koatuu=*" -o=../temp/ua.boundaries.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations=" ( route=bus =trolleybus =share_taxi =tram =road ) and type=route" -o=../temp/ua.routes.0.o5m
./osmconvert ../temp/ua.routes.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.routes.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations="type=restriction =street =associatedStreet" -o=../temp/ua.relations.0.o5m
./osmconvert ../temp/ua.relations.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.relations.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations="type=multipolygon =boundary =waterway" -o=../temp/ua.multipolygons.0.o5m
./osmconvert ../temp/ua.multipolygons.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.multipolygons.o5m
./osmfilter ../temp/ua.o5m --keep="addr:street=* or addr:housename=* or addr:housenumber=* or ( building=* and name=* ) " -o=../temp/ua.address.0.o5m
./osmconvert ../temp/ua.address.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.address.o5m
wget http://osm.org/api/0.6/node/1464223496 -O ../temp/bile.osm
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

cp -f data/*.txt $pg_data_folder
$psql_exe -f data/osm.load.data.sql

cp -f exceptions/*.exc $pg_data_folder
$psql_exe -f exceptions/osm.load.exceptions.sql

#rem Copying street names list
if [ ! -e $pg_data_folder"street_names/" ]
  then
    mkdir $pg_data_folder"street_names/"
fi

#Loading decommunization data
echo "drop table if exists cityDC;" > temp/load.decommunization.data.sql
echo "create table cityDC(koatuu text,name text,linestring geometry(Geometry,4326));" >> temp/load.decommunization.data.sql
echo "drop table if exists streets_renaming;" >> temp/load.decommunization.data.sql
echo "create table streets_renaming(koatuu text,old_name text,new_name text);" >> temp/load.decommunization.data.sql

for a in $pg_data_folder/street_renamings/*.csv
do
  csv=$(basename $a)
  koatuu=${csv:0:10}
  echo "insert into cityDC(koatuu) values('$koatuu');" >> temp/load.decommunization.data.sql 
  echo "copy streets_renaming(old_name,new_name) from 'osm/street_renamings/$csv' csv quote '\"';" >> temp/load.decommunization.data.sql
  echo "update streets_renaming set koatuu='$koatuu' where koatuu is null;" >> temp/load.decommunization.data.sql
done

echo "update cityDC cdc set linestring = (select r.linestring from node_tags nt inner join node_tags ntn on ntn.node_id=nt.node_id and ntn.k='name' inner join nodes n on n.id=ntn.node_id inner join relations r on st_contains(r.linestring,n.geom) inner join relation_tags rtk on rtk.relation_id=r.id and rtk.k='name' and rtk.v=ntn.v and rtk.relation_id in (select relation_id from relation_tags where k='place') where nt.k='koatuu' and nt.v=cdc.koatuu);" >> temp/load.decommunization.data.sql

$psql_exe -f temp/load.decommunization.data.sql

exit 0