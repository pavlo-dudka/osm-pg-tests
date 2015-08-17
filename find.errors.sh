#!/bin/sh/

if [ -e config.sh ]; then
  source ./config.sh
fi

mkdir results
$psql_exe -f sql/osm.multipolygons.sql -o results/multipolygons.geojson > /dev/null 2>&1 & #"multipolygons"
$psql_exe -f sql/osm.street.relations.sql -o results/street.relations.geojson > /dev/null 2>&1 & #"street.relations"
$psql_exe -f sql/osm.street.relations.m.sql -o results/street.relations.m.geojson > /dev/null 2>&1 & #"street.relations.m"
$psql_exe -f sql/osm.street.relations.n.sql -o results/street.relations.n.geojson > /dev/null 2>&1 & #"street.relations.n"
$psql_exe -f sql/osm.street.relations.o.sql -o results/street.relations.o.geojson > /dev/null 2>&1 & #"street.relations.o"
$psql_exe -f sql/osm.addr.housenumber.geo.sql -o results/house.numbers.geojson > /dev/null 2>&1 & #"addr.housenumber"
$psql_exe -f sql/osm.cities.without.place.polygon.sql -o results/cities.without.place.polygon.geojson > /dev/null 2>&1 & #"cities.without.place.polygon"
$psql_exe -f sql/osm.waterways.sql -o results/waterways.layer.geojson > /dev/null 2>&1 & #"waterways.layer"

#"non-uk"
./test.non-uk.sh > /dev/null 2>&1 &

#"highways"
./test.highways.sh  /dev/null 2>&1 &

#start "test"
$psql_exe -f sql/osm.test.sql -o results/osm.test.txt /dev/null 2>&1 &
#start "test.places"
$psql_exe -f sql/osm.test.places.sql -o results/osm.test.places.txt /dev/null 2>&1 &
#start "koatuu"
$psql_exe -f sql/osm.koatuu.sql -o results/osm.koatuu.txt /dev/null 2>&1 &
#start "pt.errors"
$psql_exe -f sql/osm.pt.errors.sql -o results/osm.pt.errors.txt /dev/null 2>&1 &
#start "pt.errors.2"
$psql_exe -f sql/osm.pt.errors.2.sql -o results/osm.pt.errors.2.txt /dev/null 2>&1 &
#start "roads"
$psql_exe -f sql/osm.roads.sql -o results/osm.roads.txt /dev/null 2>&1 &
#start "routes"
$psql_exe -f sql/osm.routes.sql -o results/osm.routes.txt /dev/null 2>&1 &
#start "roads.ref"
$psql_exe -f sql/osm.roads.ref.sql -o results/osm.roads.ref.txt /dev/null 2>&1 &
#start "addr.housenumber"
$psql_exe -f sql/osm.addr.housenumber.txt.sql -o results/osm.addr.housenumber.txt /dev/null 2>&1 &

#start "ternopil"
$psql_exe -f sql/osm.ternopil.sql -o results/osm.ternopil.txt /dev/null 2>&1 &
#start "berdychiv"
$psql_exe -f sql/osm.berdychiv.sql -o results/osm.Berdychiv.txt /dev/null 2>&1 &
#start "chernihiv"
$psql_exe -f sql/osm.chernihiv.sql -o results/osm.Chernihiv.txt /dev/null 2>&1 &
#start "chernivtsi"
#$psql_exe -f sql/osm.chernivtsi.sql -o results/osm.Chernivtsi.txt /dev/null 2>&1 &
#start "chernivtsi.sl"
#$psql_exe -f sql/osm.chernivtsi.sl.sql -o results/osm.Chernivtsi.sl.txt /dev/null 2>&1 &
#start "dnipropetrovsk"
$psql_exe -f sql/osm.dnipropetrovsk.sql -o results/osm.Dnipropetrovsk.txt /dev/null 2>&1 &
#start "donetsk"
$psql_exe -f sql/osm.donetsk.sql -o results/osm.Donetsk.txt /dev/null 2>&1 &
#start "ivano-frankivsk"
$psql_exe -f sql/osm.ivano_frankivsk.sql -o results/osm.Ivano-Frankivsk.txt /dev/null 2>&1 &
#start "kamianets-podilskyi"
$psql_exe -f sql/osm.kamianets_podilskyi.sql -o results/osm.Kamianets-Podilskyi.txt /dev/null 2>&1 &
#start "kirovohrad"
$psql_exe -f sql/osm.kirovohrad.sql -o results/osm.Kirovohrad.txt /dev/null 2>&1 &
#start "kremenchuk"
$psql_exe -f sql/osm.kremenchuk.sql -o results/osm.Kremenchuk.txt /dev/null 2>&1 &
#start "kyiv"
$psql_exe -f sql/osm.kyiv.sql -o results/osm.Kyiv.txt /dev/null 2>&1 &
#start "kyiv.building.levels"
$psql_exe -f sql/osm.kyiv.building.levels.sql -o results/kyiv.building.levels.geojson /dev/null 2>&1 &
#start "mariupol" 
$psql_exe -f sql/osm.mariupol.sql -o results/osm.Mariupol.txt /dev/null 2>&1 &
#start "sloviansk"
$psql_exe -f sql/osm.sloviansk.sql -o results/osm.Sloviansk.txt /dev/null 2>&1 &
#start "sumy"
$psql_exe -f sql/osm.sumy.sql -o results/osm.Sumy.txt /dev/null 2>&1 &
#start "zhytomyr"
$psql_exe -f sql/osm.zhytomyr.sql -o results/osm.Zhytomyr.txt /dev/null 2>&1 &

PROCESS="psql"
while :
  do
    RESULT=`pgrep ${PROCESS}`
      if [ "${RESULT:-null}" = null ]; then
        exit 0
      fi
    sleep 5
done

exit 0
