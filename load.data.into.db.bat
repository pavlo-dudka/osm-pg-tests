cd binaries
move ..\temp\ua.filtered.o5m ..\temp\ua.filtered.old.o5m
call osmconvert.exe ..\temp\ua.osm.pbf -o=..\temp\ua.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-ways="highway=motorway =motorway_link =trunk =trunk_link =primary =primary_link =secondary =secondary_link =tertiary =tertiary_link =unclassified =residential =living_street" -o=..\temp\ua.roads.0.o5m
call osmconvert.exe ..\temp\ua.roads.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.roads.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-nodes="place=city =town =village =hamlet" --drop-nodes="abandoned=*" -o=..\temp\ua.places.0.o5m
call osmconvert.exe ..\temp\ua.places.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.places.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="( admin_level=4 =6 ) and koatuu=*" --drop-relations="place=city_district" -o=..\temp\ua.boundaries.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="( route=bus =trolleybus =share_taxi =tram =road ) and type=route" -o=..\temp\ua.routes.0.o5m
call osmconvert.exe ..\temp\ua.routes.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.routes.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="type=restriction =street =associatedStreet" -o=..\temp\ua.relations.0.o5m
call osmconvert.exe ..\temp\ua.relations.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.relations.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="type=multipolygon" -o=..\temp\ua.multipolygons.0.o5m
call osmconvert.exe ..\temp\ua.multipolygons.0.o5m -B=..\poly\poly.ukr.pol --complex-ways -o=..\temp\ua.multipolygons.o5m
call osmconvert.exe ..\temp\ua.roads.o5m ..\temp\ua.places.o5m ..\temp\ua.boundaries.o5m ..\temp\ua.routes.o5m ..\temp\ua.relations.o5m ..\temp\ua.multipolygons.o5m -o=..\temp\ua.filtered.o5m
del                 ..\temp\ua.roads.o5m ..\temp\ua.places.o5m ..\temp\ua.boundaries.o5m ..\temp\ua.routes.o5m ..\temp\ua.relations.o5m ..\temp\ua.multipolygons.o5m
del ..\temp\ua.o5m
del ..\temp\*.0.o5m

if     exist ..\temp\ua.filtered.old.o5m (call osmconvert.exe ..\temp\ua.filtered.old.o5m ..\temp\ua.filtered.o5m --diff -o=..\temp\ua.filtered.osc)
if     exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --rxc ..\temp\ua.filtered.osc --wsc user="postgres" password="postgres" host="localhost:5432")
if not exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --ts user="postgres" password="postgres" host="localhost:5432")
if not exist ..\temp\ua.filtered.old.o5m (call osmconvert.exe ..\temp\ua.filtered.o5m -o=..\temp\ua.filtered.pbf)
if not exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --rb ..\temp\ua.filtered.pbf --lp --ws user="postgres" password="postgres" host="localhost:5432" nodeLocationStoreType="InMemory")
del ..\temp\ua.filtered.old.o5m
del ..\temp\ua.filtered.pbf
del ..\temp\ua.filtered.osc

"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -U postgres -w -d osm -p 5432 -f ..\sql\osm.boundaries.sql -q

cd ..