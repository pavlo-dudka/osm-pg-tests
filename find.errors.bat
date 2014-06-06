call config.bat

md results
call test.non-uk.bat
call test.highways.bat
call test.translation.bat

%psql_exe% -f sql\osm.sharp.turns.sql -o results\sharp.turns.geojson
%psql_exe% -f sql\osm.multipolygons.sql -o results\multipolygons.geojson
%psql_exe% -f sql\osm.street.relations.sql -o results\street.relations.geojson
%psql_exe% -f sql\osm.street.relations.m.sql -o results\street.relations.m.geojson
%psql_exe% -f sql\osm.street.relations.n.sql -o results\street.relations.n.geojson
%psql_exe% -f sql\osm.street.relations.o.sql -o results\street.relations.o.geojson
%psql_exe% -f sql\osm.addr.housenumber.geo.sql -o results\house.numbers.geojsont

%psql_exe% -f sql\osm.test.sql -o results\osm.test.txt
%psql_exe% -f sql\osm.test.places.sql -o results\osm.test.places.txt
%psql_exe% -f sql\osm.pt.errors.sql -o results\osm.pt.errors.txt
%psql_exe% -f sql\osm.pt.errors.2.sql -o results\osm.pt.errors.2.txt
%psql_exe% -f sql\osm.roads.sql -o results\osm.roads.txt
%psql_exe% -f sql\osm.routes.sql -o results\osm.routes.txt
%psql_exe% -f sql\osm.roads.ref.sql -o results\osm.roads.ref.txt
%psql_exe% -f sql\osm.addr.housenumber.txt.sql -o results\osm.addr.housenumber.txt

%psql_exe% -f sql\osm.ternopil.sql -o results\osm.ternopil.txt
%psql_exe% -f sql\osm.chernihiv.sql -o results\osm.Chernihiv.txt
rem start "chernivtsi" %psql_exe% -f sql\osm.chernivtsi.sql -o results\osm.Chernivtsi.txt
rem start "chernivtsi.sl" %psql_exe% -f sql\osm.chernivtsi.sl.sql -o results\osm.Chernivtsi.sl.txt
%psql_exe% -f sql\osm.dnipropetrovsk.sql -o results\osm.Dnipropetrovsk.txt
rem start "donetsk" %psql_exe% -f sql\osm.donetsk.sql -o results\osm.Donetsk.txt
%psql_exe% -f sql\osm.ivano_frankivsk.sql -o results\osm.Ivano-Frankivsk.txt
%psql_exe% -f sql\osm.kamianets_podilskyi.sql -o results\osm.Kamianets-Podilskyi.txt
%psql_exe% -f sql\osm.kirovohrad.sql -o results\osm.Kirovohrad.txt
%psql_exe% -f sql\osm.kyiv.sql -o results\osm.Kyiv.txt

:wait
tasklist /FI "IMAGENAME eq psql.exe" 2>NUL | find /I /N "psql.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 5
if "%ERRORLEVEL%" equ "0" goto :wait