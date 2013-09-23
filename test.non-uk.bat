%psql_exe% -f sql\osm.non-uk.sql
start "non-uk.geo" %psql_exe% -f sql\osm.non-uk.2.sql -o results\non-uk.geojsont
start "non-uk.txt" %psql_exe% -f sql\osm.non-uk.txt.sql -o results\osm.non-uk.txt
exit