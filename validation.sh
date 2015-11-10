#!/bin/sh

if [ -e config.sh ]; then
  source ./config.sh
fi

if [ -e update.pbf.sh ]; then
  ./update.pbf.sh
fi

if [ -e load.data.into.db.sh ]; then
  ./load.data.into.db.sh
fi

if [ -e find.errors.sh ]; then
  ./find.errors.sh
fi

#if [ -e peirce.sh ]; then
#  exec peirce.sh
#fi

if [ -e publish.results.now.sh ]; then
  # ./publish.results.now.sh
fi

$psql_exe -f sql/osm.vacuum.full.sql