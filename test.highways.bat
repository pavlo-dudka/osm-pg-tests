call config.bat

%psql_exe% -f sql\osm.highways.sql
call test.endNodes.bat
%psql_exe% -f sql\osm.highway.crossings.sql -o results\highway.crossings.geojson
%psql_exe% -f sql\osm.no.highways.sql -o results\no.highways.geojson
%psql_exe% -f sql\osm.neighbour.names.sql -o results\osm.neighbour.names.txt
%psql_exe% -f sql\osm.street.names.sql -o results\osm.street.names.txt
%psql_exe% -f sql\osm.restrictions.sql -o results\osm.restrictions.txt