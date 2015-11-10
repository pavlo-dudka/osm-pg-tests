@set host=localhost
@set port=5432
@set username=postgres
@set password=postgres
@set database=osm
@set pgbin_folder="C:\Program Files\PostgreSQL\9.4\bin\"
@set psql_exe="C:\Program Files\PostgreSQL\9.4\bin\psql.exe" -h %host% -p %port% -U %username% -w -d %database% -A -t -q
@set pg_data_folder=C:\Program Files\PostgreSQL\9.4\data\osm\

@set PGPASSWORD=%password%
@set PGCLIENTENCODING=utf-8