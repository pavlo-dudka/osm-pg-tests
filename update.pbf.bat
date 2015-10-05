md temp
if not exist temp\UA.osm.pbf (binaries\wget.exe http://data.gis-lab.info/osm_dump/dump/latest/UA.osm.pbf -O temp\UA.osm.pbf)
move temp\ua.osm.pbf temp\ua.0.pbf
cd binaries
osmupdate.exe ..\temp\UA.0.pbf ..\temp\UA.1.pbf --hour --max-merge=2 -v --keep-tempfiles --tempfiles=..\temp\osmupdate\
osmconvert.exe ..\temp\UA.1.pbf -o=..\temp\ua.osm.pbf -B=..\poly\ua.poly --complete-ways --complex-ways
cd ..
if exist temp\UA.osm.pbf del temp\ua.0.pbf temp\ua.1.pbf
if exist temp\ua.0.pbf move temp\ua.0.pbf temp\ua.osm.pbf