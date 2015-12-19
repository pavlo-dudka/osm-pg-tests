
#!/bin/sh

if [ ! -e temp ]
  then
    mkdir temp
fi

if [ ! -e temp/UA.osm.pbf ]
  then
    wget http://data.gis-lab.info/osm_dump/dump/latest/UA.osm.pbf -O temp/UA.osm.pbf
fi

mv temp/UA.osm.pbf temp/UA.0.pbf

cd bin

if [ ! -e osmupdate ]
  then
    wget -O - http://m.m.i24.cc/osmupdate.c | cc -x c - -o osmupdate
  else
    ./osmupdate ../temp/UA.0.pbf ../temp/UA.1.pbf --minute --max-merge=2 -v --keep-tempfiles --tempfiles=../temp/osmupdate/
    ./osmconvert ../temp/UA.1.pbf -o=../temp/UA.osm.pbf -B=../poly/UA.poly --complete-ways --complex-ways
fi

cd ..

if [ -e temp/UA.osm.pbf ]
  then
    rm temp/UA.0.pbf
    rm temp/UA.1.pbf
fi

if [ -e temp/UA.0.pbf ]
  then
    mv temp/UA.0.pbf temp/UA.osm.pbf
fi

exit 0
