call config.bat

md results
start "multipolygons" %psql_exe% -f sql\osm.multipolygons.sql -o results\multipolygons.geojson
start "street.relations" %psql_exe% -f sql\osm.street.relations.sql -o results\street.relations.geojson
start "street.relations.m" %psql_exe% -f sql\osm.street.relations.m.sql -o results\street.relations.m.geojson
start "street.relations.n" %psql_exe% -f sql\osm.street.relations.n.sql -o results\street.relations.n.geojson
start "street.relations.o" %psql_exe% -f sql\osm.street.relations.o.sql -o results\street.relations.o.geojson
start "addr.housenumber" %psql_exe% -f sql\osm.addr.housenumber.geo.sql -o results\house.numbers.geojson
start "cities.without.place.polygon" %psql_exe% -f sql\osm.cities.without.place.polygon.sql -o results\cities.without.place.polygon.geojson
start "waterways.layer" %psql_exe% -f sql\osm.waterways.sql -o results\waterways.layer.geojson
start "place.districts" %psql_exe% -f sql\osm.place.districts.sql -o results\place.districts.geojson

start "non-uk" test.non-uk.bat
start "highways" test.highways.bat
start "railways" test.railways.bat

start "test" %psql_exe% -f sql\osm.test.sql -o results\osm.test.txt
start "test.places" %psql_exe% -f sql\osm.test.places.sql -o results\osm.test.places.txt
start "koatuu" %psql_exe% -f sql\osm.koatuu.sql -o results\osm.koatuu.txt
rem start "pt.errors" %psql_exe% -f sql\osm.pt.errors.sql -o results\osm.pt.errors.txt
rem start "pt.errors.2" %psql_exe% -f sql\osm.pt.errors.2.sql -o results\osm.pt.errors.2.txt
start "roads" %psql_exe% -f sql\osm.roads.sql -o results\osm.roads.txt
start "routes" %psql_exe% -f sql\osm.routes.sql -o results\osm.routes.txt
start "roads.ref" %psql_exe% -f sql\osm.roads.ref.sql -o results\osm.roads.ref.txt
start "addr.housenumber" %psql_exe% -f sql\osm.addr.housenumber.txt.sql -o results\osm.addr.housenumber.txt

rem start "ternopil" %psql_exe% -f sql\osm.ternopil.sql -o results\osm.ternopil.txt
start "berdychiv" %psql_exe% -f sql\osm.berdychiv.sql -o results\osm.Berdychiv.txt
start "chernihiv" %psql_exe% -f sql\osm.chernihiv.sql -o results\osm.Chernihiv.txt
rem start "chernivtsi" %psql_exe% -f sql\osm.chernivtsi.sql -o results\osm.Chernivtsi.txt
rem start "chernivtsi.sl" %psql_exe% -f sql\osm.chernivtsi.sl.sql -o results\osm.Chernivtsi.sl.txt
start "dnipropetrovsk" %psql_exe% -f sql\osm.dnipropetrovsk.sql -o results\osm.Dnipropetrovsk.txt
start "donetsk" %psql_exe% -f sql\osm.donetsk.sql -o results\osm.Donetsk.txt
start "ivano-frankivsk" %psql_exe% -f sql\osm.ivano_frankivsk.sql -o results\osm.Ivano-Frankivsk.txt
start "kamianets-podilskyi" %psql_exe% -f sql\osm.kamianets_podilskyi.sql -o results\osm.Kamianets-Podilskyi.txt
start "kirovohrad" %psql_exe% -f sql\osm.kirovohrad.sql -o results\osm.Kirovohrad.txt
start "kremenchuk" %psql_exe% -f sql\osm.kremenchuk.sql -o results\osm.Kremenchuk.txt
start "kyiv" %psql_exe% -f sql\osm.kyiv.sql -o results\osm.Kyiv.txt
start "kyiv.building.levels" %psql_exe% -f sql\osm.kyiv.building.levels.sql -o results\kyiv.building.levels.geojson
start "mariupol" %psql_exe% -f sql\osm.mariupol.sql -o results\osm.Mariupol.txt
start "sloviansk" %psql_exe% -f sql\osm.sloviansk.sql -o results\osm.Sloviansk.txt
start "sumy" %psql_exe% -f sql\osm.sumy.sql -o results\osm.Sumy.txt
start "zhytomyr" %psql_exe% -f sql\osm.zhytomyr.sql -o results\osm.Zhytomyr.txt

:wait
tasklist /FI "IMAGENAME eq psql.exe" 2>NUL | find /I /N "psql.exe">NUL
if "%ERRORLEVEL%" equ "0" timeout 5
if "%ERRORLEVEL%" equ "0" goto :wait