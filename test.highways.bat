call config.bat

%psql_exe% -f sql\osm.highways.sql
start "almost.junctions" %psql_exe% -f sql\osm.almost.junctions.sql -o results\almost.junctions.geojson
start "highway.crossings" %psql_exe% -f sql\osm.highway.crossings.sql -o results\highway.crossings.geojson
start "no.highways" %psql_exe% -f sql\osm.no.highways.sql -o results\no.highways.geojson
start "neighbour.names" %psql_exe% -f sql\osm.neighbour.names.sql -o results\osm.neighbour.names.txt
start "street.names" %psql_exe% -f sql\osm.street.names.sql -o results\osm.street.names.txt
start "restrictions" %psql_exe% -f sql\osm.restrictions.sql -o results\osm.restrictions.txt
exit