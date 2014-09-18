@set host=localhost
@set port=5432
@set username=postgres
@set password=postgres
@set database=osm
@set pgbin_folder="d:\Program Files\PostgreSQL\9.3\bin\"
@set psql_exe="d:\Program Files\PostgreSQL\9.3\bin\psql.exe" -h %host% -p %port% -U %username% -w -d %database% -A -t -q
@set pg_data_folder=C:\Users\pdudka.ILS-UA\postgres\data\osm\