md results
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.highway.crossings.sql -o results\highway.crossings.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.no.highways.sql -o results\no.highways.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.sharp.turns.sql -o results\sharp.turns.geojson -q
rem "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.zigzags.sql -o results\zigzags.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.multipolygons.sql -o results\multipolygons.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.street.relations.sql -o results\street.relations.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.street.relations.2.sql -o results\street.relations.geojsont -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.almost.junctions.sql -o results\almost.junctions.geojson -q

"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.sql
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.2.sql -o results\non-uk.geojsont
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.txt.sql -o results\osm.non-uk.txt

"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.test.sql -o results\osm.test.txt
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.pt.errors.sql -o results\osm.pt.errors.txt
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.pt.errors.2.sql -o results\osm.pt.errors.2.txt
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.restrictions.sql -o results\osm.restrictions.txt
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.roads.sql -o results\osm.roads.txt -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.routes.sql -o results\osm.routes.txt -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.roads.ref.sql -o results\osm.roads.ref.txt -q

copy /Y results\*.geojson C:\Users\pdudka\Dropbox\Public\test\geojson\
move /Y results\*.geojsont C:\Users\pdudka\Dropbox\Public\test\geojson\
move /Y results\osm.test.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.pt.errors.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.pt.errors.2.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.restrictions.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.non-uk.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.roads.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.routes.txt C:\Users\pdudka\Dropbox\Public\test\txt\
move /Y results\osm.roads.ref.txt C:\Users\pdudka\Dropbox\Public\test\txt\
