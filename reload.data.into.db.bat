call config.bat

cd binaries
call osmosis-latest\bin\osmosis --ts user="%username%" password="%password%" host="%host%:%port%"
call osmconvert.exe ..\temp\ua.filtered.o5m -o=..\temp\ua.filtered.pbf
call osmosis-latest\bin\osmosis --rb ..\temp\ua.filtered.pbf --lp --ws user="%username%" password="%password%" host="%host%:%port%" nodeLocationStoreType="InMemory"
