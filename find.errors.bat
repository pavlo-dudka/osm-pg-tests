md results
start "sharp.turns" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.sharp.turns.sql -o results\sharp.turns.geojson -q
start "multipolygons" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.multipolygons.sql -o results\multipolygons.geojson -q
start "street.relations" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.street.relations.sql -o results\street.relations.geojson -q
start "street.relations.t" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.street.relations.2.sql -o results\street.relations.geojsont -q

start "non-uk" test.non-uk.bat
start "highways" test.highways.bat

start "test" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.test.sql -o results\osm.test.txt
start "pt.errors" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.pt.errors.sql -o results\osm.pt.errors.txt
start "pt.errors.2" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.pt.errors.2.sql -o results\osm.pt.errors.2.txt
start "restrictions" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.restrictions.sql -o results\osm.restrictions.txt
start "roads" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.roads.sql -o results\osm.roads.txt -q
start "routes" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.routes.sql -o results\osm.routes.txt -q
start "roads.ref" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.roads.ref.sql -o results\osm.roads.ref.txt -q
start "addr.housenumber" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.addr.housenumber.sql -o results\osm.addr.housenumber.txt -q

:wait
tasklist /FI "IMAGENAME eq psql.exe" 2>NUL | find /I /N "psql.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 5
if "%ERRORLEVEL%" equ "0" goto :wait

copy /Y results\*.geojson C:\Users\pdudka\Dropbox\Public\test\geojson\
move /Y results\*.geojsont C:\Users\pdudka\Dropbox\Public\test\geojson\
move /Y results\*.txt C:\Users\pdudka\Dropbox\Public\test\txt\
