binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-C.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-C.mp_addr.xml"
binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-E.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-E.mp_addr.xml"
binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-N.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-N.mp_addr.xml"
binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-S.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-S.mp_addr.xml"
binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-W.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-W.mp_addr.xml"
binaries\wget.exe http://peirce.zkir.ru/ADDR_CHK/UA-OVRV.mp_addr.xml -O "C:\Program Files\PostgreSQL\9.2\data\osm\UA-OVRV.mp_addr.xml"

"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\import.sql -o temp\peirce.import.txt -q

"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\citiesWithoutPlacePolygon.sql -o results\peirce.citiesWithoutPlacePolygon.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\duplicatedEdges.sql -o results\peirce.duplicatedEdges.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\deadEnds.sql -o results\peirce.deadEnds.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\subGraphs.sql -o results\peirce.subGraphs.geojson -q
"c:\Program Files\PostgreSQL\9.2\bin\psql.exe" -A -t -U postgres -w -d osm -p 5432 -f peirce\tertiarySubGraphs.sql -o results\peirce.tertiarySubGraphs.geojson -q