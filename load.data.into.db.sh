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

./osmfilter ../temp/ua.o5m --keep= --keep-relations=" ( admin_level=4 =6 ) and koatuu=*" -o=../temp/ua.regions.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-nodes="place=*" -o=../temp/ua.nodes.0.o5m
./osmconvert ../temp/ua.nodes.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.nodes.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-ways="natural=* or place=* or highway=* or waterway=* or railway=* or aeroway=* or leisure=* or amenity=*" -o=../temp/ua.ways.0.o5m
./osmconvert ../temp/ua.ways.0.o5m -B=../poly/poly.ukr.pol --complete-ways -o=../temp/ua.ways.o5m
./osmfilter ../temp/ua.o5m --keep= --keep-relations="type=restriction =street =associatedStreet =route =multipolygon =boundary =waterway" -o=../temp/ua.relations.0.o5m
./osmconvert ../temp/ua.relations.0.o5m -B=../poly/poly.ukr.pol --complex-ways -o=../temp/ua.relations.o5m
./osmfilter ../temp/ua.o5m --keep="addr:street=* or addr:housename=* or addr:housenumber=* or ( building=* and name=* ) " -o=../temp/ua.address.0.o5m
./osmconvert ../temp/ua.address.0.o5m -B=../poly/poly.ukr.pol -o=../temp/ua.address.o5m
wget http://openstreetmap.org/api/0.6/node/1464223496 -O ../temp/bile.osm
./osmconvert ../temp/ua.regions.o5m ../temp/ua.nodes.o5m  ../temp/ua.ways.o5m ../temp/ua.relations.o5m ../temp/ua.address.o5m ../temp/bile.osm -o=../temp/ua.filtered.o5m
rm ../temp/ua.regions.o5m ../temp/ua.nodes.o5m ../temp/ua.ways.o5m ../temp/ua.relations.o5m ../temp/ua.address.o5m
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

cp -f data/*.csv $pg_data_folder

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
