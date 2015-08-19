#!/bin/sh
if [ !-e temp/UA.osm.pbf]
 then
    wget http://data.gis-lab.info/osm_dump/dump/latest/UA.osm.pbf -O temp/UA.osm.pbf
fi

mv temp/ua.osm.pbf temp/ua.0.pbf

cd bin
osmupdate ../temp/UA.0.pbf ../temp/ua.osm.pbf --minute -v -B=../poly/ua.poly --complex-ways --keep-tempfiles --tempfiles=../temp/osmupdate/

cd ..
if [ -e temp/UA.osm.pbf ]
  then
    rm temp\ua.0.pbf
fi

if [ -e temp/ua.0.pbf ]
  then
  mv temp/ua.0.pbf temp/ua.osm.pbf
fi

exit 0
