#!/bin/sh

host=localhost
port=5432
username=postgres
password=postgres
database=osm
pgbin_folder="C:/Progra~1/PostgreSQL/9.4/bin"
psql_exe="$pgbin_folder/psql -h $host -p $port -U $username -w -d $database -A -t -q"
pg_data_folder="C:/Progra~1/PostgreSQL/9.4/data/osm/"
if [ ! -e $pg_data_folder ]
  then
    mkdir $pg_data_folder
fi
