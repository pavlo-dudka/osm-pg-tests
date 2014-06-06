call config.bat

cd binaries
call osmosis-latest\bin\osmosis --ts user="%username%" password="%password%" host="%host%:%port%"
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