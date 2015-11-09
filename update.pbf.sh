
#!/bin/sh

if [ ! -e temp ]
  then
    mkdir temp
fi

if [ ! -e temp/UA.osm.pbf ]
  then
    bin/wget http://data.gis-lab.info/osm_dump/dump/latest/UA.osm.pbf -O temp/UA.osm.pbf
fi

mv temp/UA.osm.pbf temp/ua.0.pbf

cd bin

if [ ! -e osmupdate ]
  then
    bin/wget -O - http://m.m.i24.cc/osmupdate.c | cc -x c - -o osmupdate
  else
    ./osmupdate ../temp/ua.0.pbf ../temp/ua.1.pbf --hour --max-merge=2 -v --keep-tempfiles --tempfiles=../temp/osmupdate/
    ./osmconvert ../temp/ua.1.pbf -o=../temp/ua.osm.pbf -B=../poly/ua.poly --complete-ways --complex-ways
fi

cd ..

if [ -e temp/UA.osm.pbf ]
  then
    rm temp/ua.0.pbf
    rm temp/ua.1.pbf
fi

if [ -e temp/ua.0.pbf ]
  then
    mv temp/ua.0.pbf temp/UA.osm.pbf
fi

exit 0
