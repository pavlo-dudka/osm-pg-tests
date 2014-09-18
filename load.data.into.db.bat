call config.bat

cd binaries
move ..\temp\ua.filtered.o5m ..\temp\ua.filtered.old.o5m
call osmconvert.exe ..\temp\ua.osm.pbf -o=..\temp\ua.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-ways="highway=motorway =motorway_link =trunk =trunk_link =primary =primary_link =secondary =secondary_link =tertiary =tertiary_link =unclassified =residential =living_street =service =pedestrian =construction" -o=..\temp\ua.roads.0.o5m
call osmconvert.exe ..\temp\ua.roads.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.roads.o5m
call osmfilter.exe ..\temp\ua.o5m --keep="place=city =town =village =hamlet" -o=..\temp\ua.places.0.o5m
call osmconvert.exe ..\temp\ua.places.0.o5m -B=..\poly\poly.ukr.pol --complex-ways -o=..\temp\ua.places.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations=" ( admin_level=4 =6 =7 =8 ) and koatuu=*" -o=..\temp\ua.boundaries.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations=" ( route=bus =trolleybus =share_taxi =tram =road ) and type=route" -o=..\temp\ua.routes.0.o5m
call osmconvert.exe ..\temp\ua.routes.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.routes.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="type=restriction =street =associatedStreet" -o=..\temp\ua.relations.0.o5m
call osmconvert.exe ..\temp\ua.relations.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.relations.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="type=multipolygon =boundary" -o=..\temp\ua.multipolygons.0.o5m
call osmconvert.exe ..\temp\ua.multipolygons.0.o5m -B=..\poly\poly.ukr.pol --complex-ways -o=..\temp\ua.multipolygons.o5m
call osmfilter.exe ..\temp\ua.o5m --keep= --keep-ways="addr:street=* or addr:housename=* or addr:housenumber=* or ( building=* and name=* ) " -o=..\temp\ua.address.0.o5m
call osmconvert.exe ..\temp\ua.address.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.address.o5m
rem call osmfilter.exe ..\temp\ua.o5m --keep= --keep-relations="name:en=Donetsk =Chernihiv" -o=..\temp\ua.cities.o5m
rem call osmfilter.exe ..\temp\ua.o5m --keep="amenity=* or historic=*" -o=..\temp\ua.poi.0.o5m
rem call osmconvert.exe ..\temp\ua.poi.0.o5m -B=..\poly\poly.ukr.pol -o=..\temp\ua.poi.o5m
call wget.exe http://osm.org/api/0.6/node/1464223496 -O ..\temp\bile.osm
call osmconvert.exe ..\temp\ua.roads.o5m ..\temp\ua.places.o5m ..\temp\ua.boundaries.o5m ..\temp\ua.routes.o5m ..\temp\ua.relations.o5m ..\temp\ua.multipolygons.o5m ..\temp\ua.address.o5m ..\temp\bile.osm -o=..\temp\ua.filtered.o5m
del                 ..\temp\ua.roads.o5m ..\temp\ua.places.o5m ..\temp\ua.boundaries.o5m ..\temp\ua.routes.o5m ..\temp\ua.relations.o5m ..\temp\ua.multipolygons.o5m ..\temp\ua.address.o5m
del ..\temp\ua.o5m
del ..\temp\*.0.o5m

if     exist ..\temp\ua.filtered.old.o5m (call osmconvert.exe ..\temp\ua.filtered.old.o5m ..\temp\ua.filtered.o5m --diff -o=..\temp\ua.filtered.osc)
if     exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --rxc ..\temp\ua.filtered.osc --wsc user="%username%" password="%password%" host="%host%:%port%")
if not exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --ts user="%username%" password="%password%" host="%host%:%port%")
if not exist ..\temp\ua.filtered.old.o5m (call osmconvert.exe ..\temp\ua.filtered.o5m -o=..\temp\ua.filtered.pbf)
if not exist ..\temp\ua.filtered.old.o5m (call osmosis-latest\bin\osmosis --rb ..\temp\ua.filtered.pbf --lp --ws user="%username%" password="%password%" host="%host%:%port%" nodeLocationStoreType="InMemory")
del ..\temp\ua.filtered.old.o5m
del ..\temp\ua.filtered.pbf
del ..\temp\ua.filtered.osc

cd ..

%psql_exe% -f sql\osm.boundaries.sql

cd exceptions
xcopy /Y *.exc "%pg_data_folder%"
%psql_exe% -f osm.load.exceptions.sql
cd ..

rem Copying street names list
xcopy /Y C:\Users\pdudka.ILS-UA\Dropbox\osm\data\*.csv "%pg_data_folder%street_names\"