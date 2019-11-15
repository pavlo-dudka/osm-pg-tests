#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

if [ ! -e results ]
  then
    mkdir results
fi

$psql_exe -f sql/osm.multipolygons.sql -o results/multipolygons.geojson 2>&1 & #"multipolygons"
$psql_exe -f sql/osm.addr.housenumber.geo.sql -o results/house.numbers.geojson 2>&1 & #"addr.housenumber"
$psql_exe -f sql/osm.cities.without.place.polygon.sql -o results/cities.without.place.polygon.geojson 2>&1 & #"cities.without.place.polygon"
$psql_exe -f sql/osm.waterways.sql -o results/waterways.layer.geojson 2>&1 & #"waterways.layer"
$psql_exe -f sql/osm.place.districts.sql -o results/place.districts.geojson 2>&1 & #"place.districts"
$psql_exe -f sql/osm.decommunization.sql -o results/decommunization.geojson 2>&1 & #"osm.decommunization"
$psql_exe -f sql/osm.decommunization.streets.sql -o results/decommunization.streets.geojson 2>&1 & #"osm.decommunization.streets"

echo "start test.non-uk.sh"
#"non-uk"
./test.non-uk.sh 2>&1 &

echo "start test.highways.sh"
#"highways"
./test.highways.sh 2>&1 &

./test.railways.sh 2>&1 &

./test.street.relations.sh 2>&1 &

#start "test"
$psql_exe -f sql/osm.test.sql -o results/osm.test.txt 2>&1 &
#start "test.places"
$psql_exe -f sql/osm.test.places.sql -o results/osm.test.places.txt 2>&1 &
#start "koatuu"
$psql_exe -f sql/osm.koatuu.sql -o results/osm.koatuu.txt 2>&1 &
#start "pt.errors"
#$psql_exe -f sql/osm.pt.errors.sql -o results/osm.pt.errors.txt 2>&1 &
#start "pt.errors.2"
#$psql_exe -f sql/osm.pt.errors.2.sql -o results/osm.pt.errors.2.txt 2>&1 &
#start "roads"
$psql_exe -f sql/osm.roads.sql -o results/osm.roads.txt 2>&1 &
#start "routes"
$psql_exe -f sql/osm.routes.sql -o results/osm.routes.txt 2>&1 &
#start "roads.ref"
$psql_exe -f sql/osm.roads.ref.sql -o results/osm.roads.ref.txt 2>&1 &
#start "addr.housenumber"
$psql_exe -f sql/osm.addr.housenumber.txt.sql -o results/osm.addr.housenumber.txt 2>&1 &

#start "ternopil"
#$psql_exe -f sql/osm.ternopil.sql -o results/osm.ternopil.txt 2>&1 &
#start "berdychiv"
$psql_exe -f sql/osm.berdychiv.sql -o results/osm.Berdychiv.txt 2>&1 &
#start "cherkasy"
$psql_exe -f sql/osm.cherkasy.sql -o results/osm.Cherkasy.txt 2>&1 &
#start "chernihiv"
$psql_exe -f sql/osm.chernihiv.sql -o results/osm.Chernihiv.txt 2>&1 &
#start "chernivtsi"
#$psql_exe -f sql/osm.chernivtsi.sql -o results/osm.Chernivtsi.txt 2>&1 &
#start "chernivtsi.sl"
#$psql_exe -f sql/osm.chernivtsi.sl.sql -o results/osm.Chernivtsi.sl.txt 2>&1 &
#start "dnipropetrovsk"
$psql_exe -f sql/osm.dnipropetrovsk.sql -o results/osm.Dnipropetrovsk.txt 2>&1 &
#start "donetsk"
$psql_exe -f sql/osm.donetsk.sql -o results/osm.Donetsk.txt 2>&1 &
#start "ivano-frankivsk"
$psql_exe -f sql/osm.ivano_frankivsk.sql -o results/osm.Ivano-Frankivsk.txt 2>&1 &
#start "kamianets-podilskyi"
$psql_exe -f sql/osm.kamianets_podilskyi.sql -o results/osm.Kamianets-Podilskyi.txt 2>&1 &
#start "kirovohrad"
$psql_exe -f sql/osm.kirovohrad.sql -o results/osm.Kirovohrad.txt 2>&1 &
#start "kramatorsk"
$psql_exe -f sql/osm.kramatorsk.sql -o results/osm.Kramatorsk.txt 2>&1 &
#start "kremenchuk"
$psql_exe -f sql/osm.kremenchuk.sql -o results/osm.Kremenchuk.txt 2>&1 &
#start "kyiv"
$psql_exe -f sql/osm.kyiv.sql -o results/osm.Kyiv.txt 2>&1 &
#start "kyiv.building.levels"
$psql_exe -f sql/osm.kyiv.building.levels.sql -o results/kyiv.building.levels.geojson 2>&1 &
#start "mariupol"
$psql_exe -f sql/osm.mariupol.sql -o results/osm.Mariupol.txt 2>&1 &
#start "sloviansk"
$psql_exe -f sql/osm.sloviansk.sql -o results/osm.Sloviansk.txt 2>&1 &
#start "sumy"
$psql_exe -f sql/osm.sumy.sql -o results/osm.Sumy.txt 2>&1 &
#start "zhytomyr"
$psql_exe -f sql/osm.zhytomyr.sql -o results/osm.Zhytomyr.txt 2>&1 &
#start "myrhorod"
$psql_exe -f sql/osm.myrhorod.sql -o results/osm.Myrhorod.txt 2>&1 &

for job in `jobs -p`
do
    wait $job
done

exit 0
