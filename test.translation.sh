#!/bin/bash

if [ -e config.sh ]; then
  source ./config.sh
fi

$psql_exe -f sql/osm.trans.errors.sql -o results/osm.trans.errors.txt

#start "trans.ua"
$psql_exe -f sql/osm.trans.uk.sql -o results/osm.trans.uk.txt 2>&1 &

#start "trans.ru"
$psql_exe -f sql/osm.trans.ru.sql -o results/osm.trans.ru.txt 2>&1 &

for job in `jobs -p`
do
    wait $job
done

exit 0
