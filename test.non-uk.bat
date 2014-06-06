%psql_exe% -f sql\osm.non-uk.sql
%psql_exe% -f sql\osm.non-uk.2.sql -o results\non-uk.geojsont
%psql_exe% -f sql\osm.non-uk.txt.sql -o results\osm.non-uk.txt