
#!/bin/sh

if [ ! -e temp ]
  then
    mkdir temp
fi

if [ ! -e temp/ua.o5m ]
  then
    wget https://download.geofabrik.de/europe/ukraine-latest.osm.pbf -O temp/ua.osm.pbf
    ./bin/osmconvert temp/ua.osm.pbf -o=temp/ua.o5m
    rm temp/ua.osm.pbf
elif [ -e temp/ua.filtered.o5m ]
  then
    cp temp/ua.filtered.o5m temp/ua.o5m
fi

mv temp/ua.o5m temp/ua.0.o5m

cd bin

if [ ! -e osmupdate ]
  then
    wget -O - http://m.m.i24.cc/osmupdate.c | cc -x c - -o osmupdate
  else
    ./osmupdate ../temp/ua.0.o5m ../temp/ua.1.pbf --hour --max-merge=2 -v
    ./osmupdate ../temp/ua.1.pbf ../temp/ua.o5m --minute --max-merge=5 -v
fi

cd ..

if [ -e temp/ua.o5m ]
  then
    rm temp/ua.0.o5m
    rm temp/ua.1.pbf
fi

if [ -e temp/ua.0.o5m ]
  then
    mv temp/ua.0.o5m temp/ua.o5m
fi

exit 0
