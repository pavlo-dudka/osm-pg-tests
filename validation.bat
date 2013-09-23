@set host=localhost
@set port=5432
@set username=postgres
@set password=postgres
@set database=osm
@set psql_exe="c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -h %host% -p %port% -U %username% -w -d %database% -A -t -q

call update.pbf.bat
call load.data.into.db.bat
call find.errors.bat

call build.rss.bat