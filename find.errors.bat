call config.bat

md results
start "sharp.turns" %psql_exe% -f sql\osm.sharp.turns.sql -o results\sharp.turns.geojson
start "multipolygons" %psql_exe% -f sql\osm.multipolygons.sql -o results\multipolygons.geojson
start "street.relations" %psql_exe% -f sql\osm.street.relations.sql -o results\street.relations.geojson
start "street.relations.t" %psql_exe% -f sql\osm.street.relations.2.sql -o results\street.relations.geojsont
start "street.relations.n" %psql_exe% -f sql\osm.street.relations.n.sql -o results\street.relations.n.geojson
start "street.relations.o" %psql_exe% -f sql\osm.street.relations.o.sql -o results\street.relations.o.geojson
start "addr.housenumber" %psql_exe% -f sql\osm.addr.housenumber.geo.sql -o results\house.numbers.geojsont

start "non-uk" test.non-uk.bat
start "highways" test.highways.bat
start "translation" test.translation.bat

start "test" %psql_exe% -f sql\osm.test.sql -o results\osm.test.txt
start "pt.errors" %psql_exe% -f sql\osm.pt.errors.sql -o results\osm.pt.errors.txt
start "pt.errors.2" %psql_exe% -f sql\osm.pt.errors.2.sql -o results\osm.pt.errors.2.txt
start "roads" %psql_exe% -f sql\osm.roads.sql -o results\osm.roads.txt
start "routes" %psql_exe% -f sql\osm.routes.sql -o results\osm.routes.txt
start "roads.ref" %psql_exe% -f sql\osm.roads.ref.sql -o results\osm.roads.ref.txt
start "addr.housenumber" %psql_exe% -f sql\osm.addr.housenumber.txt.sql -o results\osm.addr.housenumber.txt
start "ternopil" %psql_exe% -f sql\osm.ternopil.sql -o results\osm.ternopil.txt
start "donetsk" %psql_exe% -f sql\osm.donetsk.sql -o results\osm.Donetsk.txt
start "chernivtsi" %psql_exe% -f sql\osm.chernivtsi.sql -o results\osm.Chernivtsi.txt
start "chernivtsi.sl" %psql_exe% -f sql\osm.chernivtsi.sl.sql -o results\osm.Chernivtsi.sl.txt
start "dnipropetrovsk" %psql_exe% -f sql\osm.dnipropetrovsk.sql -o results\osm.Dnipropetrovsk.txt
start "kamianets-podilskyi" %psql_exe% -f sql\osm.kamianets_podilskyi.sql -o results\osm.Kamianets-Podilskyi.txt
start "kirovohrad" %psql_exe% -f sql\osm.kirovohrad.sql -o results\osm.Kirovohrad.txt

:wait
tasklist /FI "IMAGENAME eq psql.exe" 2>NUL | find /I /N "psql.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 5
if "%ERRORLEVEL%" equ "0" goto :wait