call binaries\osmconvert.exe temp\ua.filtered.o5m -o=temp\ua.filtered.pbf
call binaries\osmosis-latest\bin\osmosis --rs user="postgres" password="postgres" host="localhost:5432" --dd --sort --rb temp\ua.filtered.pbf --sort --dc --wxc ua.diff.osc
delete temp\ua.filtered.pbf