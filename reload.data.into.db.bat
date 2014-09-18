call config.bat

%pgbin_folder%dropdb.exe -U postgres -w osm
%pgbin_folder%createdb.exe -O postgres -U postgres -T postgis_21_sample -w osm
%psql_exe% -f sql\pg.sql

cd binaries
rem call osmosis-latest\bin\osmosis --ts user="%username%" password="%password%" host="%host%:%port%"
call osmconvert.exe ..\temp\ua.filtered.o5m -o=..\temp\ua.filtered.pbf
call osmosis-latest\bin\osmosis --rb ..\temp\ua.filtered.pbf --lp --ws user="%username%" password="%password%" host="%host%:%port%"

cd ..
%psql_exe% -f sql\osm.boundaries.sql

cd exceptions
xcopy /Y *.exc "%pg_data_folder%"
%psql_exe% -f osm.load.exceptions.sql
cd ..

rem Copying street names list
copy /Y C:\Users\pdudka.ILS-UA\Dropbox\osm\data\*.csv "%pg_data_folder%street_names"