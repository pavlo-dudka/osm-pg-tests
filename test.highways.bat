"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.highways.sql
start "almost.junctions" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.almost.junctions.sql -o results\almost.junctions.geojson -q
start "highway.crossings" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.highway.crossings.sql -o results\highway.crossings.geojson -q
start "no.highways" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.no.highways.sql -o results\no.highways.geojson -q
start "neighbour.names" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.neighbour.names.sql -o results\osm.neighbour.names.txt -q
start "street.names" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.street.names.sql -o results\osm.street.names.txt -q
exit