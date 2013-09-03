"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.sql
start "non-uk.geo" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.2.sql -o results\non-uk.geojsont
start "non-uk.txt" "c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f sql\osm.non-uk.txt.sql -o results\osm.non-uk.txt
exit