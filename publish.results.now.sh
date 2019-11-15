#!/bin/bash

if [ -e config.sh ]
  then
    source ./config.sh
fi

publish_path="/home/osm-pg-tests-gh-pages" #локальна тека
publish_url="http://pavlo-dudka.github.io/osm-pg-tests"

$psql_exe -f sql/carto.decommunization.sql -o results/carto.decommunization.sql
wget http://dudka.cartodb.com/api/v2/sql --post-file results/carto.decommunization.sql -O temp/carto.response.json

if [ -e publish.results.sh ]; then
  source ./publish.results.sh
fi

if [ -e git-push.sh ]; then
  source ./git-push.sh
fi

sleep 120s
source ./publish.mapRoulette.sh

exit 0
