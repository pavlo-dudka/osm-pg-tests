call config.bat

%psql_exe% -f sql\osm.almost.junctions.sql -o results\almost.junctions.geojson
%psql_exe% -f sql\osm.dead.ends.sql -o results\dead.nodes.geojson
exit