call config.bat

%pgbin_folder%dropdb.exe -U postgres -w osm
%pgbin_folder%createdb.exe -O postgres -U postgres -w osm
%psql_exe% -f sql\pg.sql

cd binaries
rem call osmosis-latest\bin\osmosis --ts user="%username%" password="%password%" host="%host%:%port%"
call osmconvert.exe ..\temp\ua.filtered.o5m -o=..\temp\ua.filtered.pbf
call osmosis-latest\bin\osmosis --rb ..\temp\ua.filtered.pbf --lp --ws user="%username%" password="%password%" host="%host%:%port%" database="%database%"

cd ..
%psql_exe% -f sql\osm.boundaries.sql > results\osm.boundaries.log 2>&1

cd data
xcopy /Y *.txt "%pg_data_folder%"
%psql_exe% -f osm.load.data.sql
cd ..

cd exceptions
xcopy /Y *.exc "%pg_data_folder%"
%psql_exe% -f osm.load.exceptions.sql
cd ..

rem Copying street names list
xcopy /Y C:\Users\pdudka.ILS-UA\Dropbox\osm\data\*.csv "%pg_data_folder%street_names\"
xcopy /Y C:\Users\pdudka.ILS-UA\Dropbox\osm\data\*.txt "%pg_data_folder%street_names\"
xcopy /Y C:\Users\pdudka.ILS-UA\Dropbox\osm\data\*.txt "%pg_data_folder%"