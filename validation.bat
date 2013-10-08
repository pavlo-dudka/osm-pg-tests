@set host=localhost
@set port=5432
@set username=postgres
@set password=postgres
@set database=osm
@set psql_exe="c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -h %host% -p %port% -U %username% -w -d %database% -A -t -q

call update.pbf.bat
call load.data.into.db.bat
call find.errors.bat

@set publish_path=C:\Users\pdudka\Dropbox\Public\test
@set publish_url=http://dl.dropboxusercontent.com/u/14107903/test
call publish.results.bat

@set publish_path=C:\Users\pdudka\Downloads\osm-pg-tests-page
@set publish_url=http://pavlo-dudka.github.io/osm-pg-tests
call publish.results.bat
call git-push.bat