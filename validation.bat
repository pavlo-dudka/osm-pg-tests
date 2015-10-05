call config.bat

call update.pbf.bat
call load.data.into.db.bat
call find.errors.bat

rem call peirce.bat

start "vacuum" %psql_exe% -f sql\osm.vacuum.full.sql

call publish.results.now.bat