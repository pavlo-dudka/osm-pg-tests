#!/bin/bash

host=localhost
port=5432
username=postgres
password=postgres
database=osm
pgbin_folder=
psql_exe="psql -p $port -U $username -w -d $database -A -t -q"
pg_data_folder=/var/lib/postgresql/9.6/main/osm
if [ ! -e $pg_data_folder ]
  then
    mkdir $pg_data_folder
fi

export PGPASSWORD=$password
export PGCLIENTENCODING=utf-8
